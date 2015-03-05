<?php
class CategoriesDB extends DB
{
    const TABLE = 'categories';
    private $map = array(
        'id' => array(PDO::PARAM_INT, 11),
        'name' => array(PDO::PARAM_STR, 100),
        'date_created' => array(PDO::PARAM_STR, 100),

    );
    const USER_CATEGORIES_TABLE = 'user_categories';
    private $user_categories_table = array(
        'id' => array(PDO::PARAM_INT, 11),
        'user_id' => array(PDO::PARAM_INT, 11),
        'category_id' => array(PDO::PARAM_INT, 11),
        'color' => array(PDO::PARAM_STR, 100),
        'date_created' => array(PDO::PARAM_STR, 100),
    );
    const PHACT_CATEGORIES_TABLE = 'phact_categories';
    private $phact_categories_table = array(
        'id' => array(PDO::PARAM_INT, 11),
        'phact_id' => array(PDO::PARAM_INT, 11),
        'category_id' => array(PDO::PARAM_INT, 11),
        'user_id' => array(PDO::PARAM_INT, 11),
        'date_created' => array(PDO::PARAM_STR, 100),
    );

    private $colors_list = ["red", "blue", "yellow", "black", "silver"];
    private $colors_hash = ["81ca25", "f26522", "003986", "ec008c", "fce600", "92278f", "ffa73d", "2ebdf2", "e40009", "00a013"];



    public function get($what, $where, $single = true)
    {
        $fetchMode = $single ? PhactDB::FETCH_SINGLE : PhactDB::FETCH_ALL;
        return $this->db->read(
            self::TABLE,
            $this->map,
            $what,
            $where,
            $fetchMode
        );
    }

    public function set($what, $where)
    {
        return $this->db->update(
            self::TABLE,
            $this->map,
            $what,
            $where
        );
    }

    public function getById($id, $userId = false)
    {
        $category = $this->db->read(
            self::TABLE,
            $this->map,
            null,
            array('id' => $id)
        );
        $categoryArray = get_object_vars($category);

        if ($userId) {
            $connection = $this->db->read(
                self::USER_CATEGORIES_TABLE,
                $this->user_categories_table,
                null,
                array('user_id' => $userId, 'category_id'=>$category->id)
            );
            if (!$connection) {
                return false;
            }
//            $categoryArray["color"] = $this->colors_hash[$connection->color];
            $categoryArray["color"] = $connection->color;
        }
        return $categoryArray;
    }

    public function create($data)
    {
        $this->db->create(
            self::TABLE,
            $this->map,
            $data
        );
        return $this->db->lastInsertId();
    }

    public function connectCategoryPhact($data) {
        $this->db->create(
            self::PHACT_CATEGORIES_TABLE,
            $this->phact_categories_table,
            $data, ["ignore"=>true]
        );
        return $this->db->lastInsertId();
    }

    public function disconnectCategoryPhact($data) {
        $this->db->delete(
            self::PHACT_CATEGORIES_TABLE,
            $this->phact_categories_table,
            $data
        );
        return $this->db->lastInsertId();
    }

    public function connectCategoryUser($data) {

        if (!array_key_exists("color", $data)) {
            $colorObjs = $this->db->read(self::USER_CATEGORIES_TABLE, $this->user_categories_table, ["color"], ["user_id"=>$data["user_id"]], PhactDB::FETCH_ALL);
            $colors = [];
            if ($colorObjs) {
                foreach ($colorObjs as $color) {
                    $colors[] = $color->color;
                }
                $restColors = array_diff($this->colors_hash, $colors);
                if (count($restColors)) {
                    $this->colors_hash = $restColors;
                }
            }
            $data["color"] = $this->colors_hash[array_rand($this->colors_hash)];
        }
        $this->db->create(
            self::USER_CATEGORIES_TABLE,
            $this->user_categories_table,
            $data
        );
        return $this->db->lastInsertId();
    }

    /**
     * @param $userID
     * @param $page (starts with 1)
     */
    public function getUserCategories($userID) {
        $query = sprintf('
                  SELECT
                    *
                  FROM %s AS categories
                  INNER JOIN %s AS ref_cat_user ON ref_cat_user.category_id = categories.id

                  WHERE ref_cat_user.user_id=:userID
                  ORDER BY categories.date_careated ASC

',
            self::TABLE, self::USER_CATEGORIES_TABLE
        );

        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':userID', $userID, PDO::PARAM_INT);
        $stmt->execute();
        if (!$stmt->rowCount()) {
            throw new Exception("No items found");
        }

        return $stmt->fetchAll();
    }

    /**
     * @param $ids
     * @return bool
     */
    public function markAsRead($ids) {
        $query = sprintf("UPDATE %s SET `read`=1 WHERE id IN (%s)", PhactsDB::FEED_TABLE, implode(",", $ids));

        $stmt = $this->db->prepare($query);
        $stmt->execute();
        return true;
    }

    /**
     * @param $userID
     * @return int
     */
    public function getUnreadPhactsCount($userID) {
        $query = sprintf("SELECT COUNT(1) as unreads FROM %s as shared_phacts WHERE shared_phacts.read = 0 AND shared_phacts.to_id = %d", PhactsDB::FEED_TABLE, $userID);
        $stmt = $this->db->prepare($query);

        $stmt->execute();
        $res = $stmt->fetchAll();
        return (int) $res[0]->unreads;
    }

    /**
     * @param $catID
     * @return bool
     */
    public function checkUsage($catID) {
        $rows = $this->db->read(
            self::USER_CATEGORIES_TABLE,
            $this->user_categories_table,
            array(),
            array("category_id"=>$catID));
        if ($rows) {
            return true;
        }
        return false;
    }

    /**
     * @param $catID
     * @param $userID
     * @return bool
     * @throws Exception
     */
    public function deleteCarefully($catID, $userID) {
        $c = $this->db->delete(self::USER_CATEGORIES_TABLE, $this->user_categories_table, array("category_id"=>$catID, "user_id"=>$userID));
        if (!$c) {
            throw new Exception("nothing to delete");
        }
        if (!$this->checkUsage($catID)) {
            $c = $this->db->delete(self::TABLE, $this->map, array("id"=>$catID));
        }
        return true;
    }

    public function isInCategories($phact_id) {
        return (bool)  $this->db->read(self::PHACT_CATEGORIES_TABLE, $this->phact_categories_table, [], ["phact_id"=>$phact_id]);
    }

}

?>