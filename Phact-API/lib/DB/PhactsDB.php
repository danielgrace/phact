<?php
class PhactsDB extends DB
{
    const TABLE = 'phacts';
    private $map = array(
        'id' => array(PDO::PARAM_INT, 11),
        'philter' => array(PDO::PARAM_STR, 100),
        'description' => array(PDO::PARAM_STR, 500),
        'location' => array(PDO::PARAM_STR, 100),
        'date_created' => array(PDO::PARAM_STR, 100),
        'image' => array(PDO::PARAM_STR, 100),
        'printed_image' => array(PDO::PARAM_STR, 100),
        'user_id' => array(PDO::PARAM_INT, 11),
    );


    const FEED_TABLE = 'feed';
    private $feed_table = array(
        'id' => array(PDO::PARAM_INT, 11),
        'user_id' => array(PDO::PARAM_INT, 11),
        'to_id' => array(PDO::PARAM_INT, 11),
        'from_id' => array(PDO::PARAM_INT, 11),
        'phact_id' => array(PDO::PARAM_INT, 11),
        'shared_date' => array(PDO::PARAM_STR, 100),
        'read' => array(PDO::PARAM_INT, 1),
        'pushed' => array(PDO::PARAM_INT, 1),
        'hided' => array(PDO::PARAM_INT, 1),
    );


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

    public function getById($id)
    {
        return $this->db->read(
            self::TABLE,
            $this->map,
            null,
            array('id' => $id)
        );
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

    public function createSharedPhact($data)
    {
        $this->db->create(
            self::FEED_TABLE,
            $this->feed_table,
            $data
        );
        return $this->db->lastInsertId();
    }

    public function getFeedItem($item)
    {
        return $this->db->read(self::FEED_TABLE, $this->feed_table, [], ["id" => $item]);
    }

    public function getFeedItems($where)
    {
        return $this->db->read(self::FEED_TABLE, $this->feed_table, [], $where, PhactDB::FETCH_ALL);
    }

    public function setFeedItem($what, $where)
    {
        return $this->db->update(self::FEED_TABLE, $this->feed_table, $what, $where);
    }

    /**
     * @param $userID
     * @param $page (starts with 1)
     */
    public function getFeed($userID, $page = 1, $categoryID = false)
    {
        $result = array();
        $perPage = 10;
        $offset = ($page - 1) * $perPage;
        if ($categoryID) {
            $categoryFilter = "INNER JOIN " . CategoriesDB::PHACT_CATEGORIES_TABLE . " as ref_phact_category
            ON ref_phact_category.phact_id=phacts.id" .
                " AND ref_phact_category.user_id = " . $userID .
                " AND ref_phact_category.category_id = " . $categoryID .
                "  ";

        } else {
            $categoryFilter = "";
        }
        $query = sprintf('
                  SELECT
                    feed.id as id,
                    phacts.id as phact_id,
                    phact_owner.id as usr_id_from,
                    friend.id as usr_id_to,
                    friend.usr_fname as usr_name_to,
                    phact_owner.usr_fname as usr_name_from ,
                    phacts.philter as philter,
                    phacts.description as description,
                    phacts.location as location,
                    phacts.date_created as date_created,
                    phacts.image as image,
                    phacts.printed_image as printed_image,
                    feed.read as `read`,
                    phacts.row_inserted as shared_date
                  FROM %s AS feed
                  INNER JOIN %s AS phacts ON phacts.id = feed.phact_id
                  %s
                  LEFT JOIN %s AS phact_owner ON phact_owner.id = feed.from_id
                  LEFT JOIN %s AS friend ON friend.id = feed.to_id
                  WHERE feed.user_id=%d AND feed.hided = 0
                  ORDER BY feed.shared_date DESC
                  LIMIT %d, %d
',
            self::FEED_TABLE, self::TABLE, $categoryFilter, UserDB::TABLE, UserDB::TABLE,
            $userID,
            $offset, $perPage
        );
        $stmt = $this->db->prepare($query);
//        $stmt->bindParam(':userID', $userID, PDO::PARAM_INT);
        $stmt->execute();
        if (!$stmt->rowCount()) {
            throw new Exception("No items found");
        }
        $feed = [];
        $phactsRes = $stmt->fetchAll();
        foreach ($phactsRes as $phact) {
            $feed[$phact->id] = get_object_vars($phact);

            if ($phact->usr_id_from == $userID) {
                $feed[$phact->id]["direction"] = "out";
            } else {
                $feed[$phact->id]["direction"] = "in";
            }
            $feed[$phact->id]['description'] = preg_replace('/[^0-9a-zA-Z\.\,\s]+/', '', $feed[$phact->id]['description']);
            $categories = $this->getPhactCategories($phact->phact_id, $userID);
            $feed[$phact->id]["color"] = $categories["color"];
            $feed[$phact->id]["categories"] = $categories["categories"];
            $feed[$phact->id]["shared_date"] = date('d M/Y g:i A', strtotime($phact->shared_date));
        }
        return array_values($feed);
    }

    /**
     * @param $ids
     * @return bool
     */
    public function markAsRead($ids)
    {
        $query = sprintf("UPDATE %s SET `read`=1 WHERE id IN (%s)", self::FEED_TABLE, implode(",", $ids));

        $stmt = $this->db->prepare($query);
        $stmt->execute();
        return true;
    }

    public function getUnreadPhactsCount($userID)
    {
        $query = sprintf("SELECT COUNT(1) as unreads FROM %s as feed WHERE feed.read = 0 AND feed.to_id = %d AND feed.user_id = %d", self::FEED_TABLE, $userID, $userID);
        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':userID', $userID, PDO::PARAM_INT);
        $stmt->execute();
        $res = $stmt->fetchAll();
        return (int)$res[0]->unreads;
    }

    public function getPhactCategories($phactId, $userId = false)
    {
        if ($userId) {


            $query = sprintf("select * from `%s` as phact_categories
                left join %s as `user_categories` on user_categories.category_id = phact_categories.category_id
                 and user_categories.user_id = %d
                where phact_categories.phact_id = %d and phact_categories.user_id = %d
                 order by phact_categories.connected_timestamp desc;",
                CategoriesDB::PHACT_CATEGORIES_TABLE,
                CategoriesDB::USER_CATEGORIES_TABLE,
                $userId, $phactId, $userId);
        } else {
            $query = sprintf("select * from `%s` as phact_categories
                left join %s as `user_categories` on user_categories.category_id = phact_categories.category_id
                 where phact_categories.phact_id = %d
                 order by phact_categories.connected_timestamp desc;",
                CategoriesDB::PHACT_CATEGORIES_TABLE,
                CategoriesDB::USER_CATEGORIES_TABLE,
                $phactId);
        }
        $stmt = $this->db->prepare($query);
        $stmt->execute();
        $color = [];
        $categories = [];
        if ($stmt->rowCount()) {

            $res = $stmt->fetchAll();
            foreach ($res as $row) {
                if ($row->category_id) {

                    array_push($color, $row->color);
                    array_push($categories, $row->category_id);
                }
            }

        }
        return array("color" => $color, "categories" => $categories);
    }

    public function getOwnPhacts($userId, $count = false)
    {
        if ($count) {
            $query = sprintf("
                SELECT count(1) as count FROM %s as phacts
                    WHERE phacts.user_id = %d AND (phacts.status is null OR phacts.status != 'deleted')",
                self::TABLE, $userId);
            $stmt = $this->db->prepare($query);
            $stmt->execute();
            $phacts = $stmt->fetch();
            return $phacts;
        }
        $query = sprintf("
                SELECT phacts.* FROM %s as phacts
                    WHERE phacts.user_id = %d AND (phacts.status is null OR phacts.status != 'deleted')
                    ORDER BY phacts.date_created DESC",
            self::TABLE, $userId);
        $stmt = $this->db->prepare($query, array(PDO::ATTR_CURSOR => PDO::CURSOR_SCROLL));
        $stmt->execute();
        while($row = $stmt->fetch(PDO::FETCH_OBJ, PDO::FETCH_ORI_NEXT)) {
            $phactsObjects[]=$row;
        }


//        $phactsObjects = $stmt->fetch();
//var_dump($phactsObjects);exit;
        if (!$phactsObjects or !count($phactsObjects)) {
            throw new Exception("You have no saved phacts, go ahead and create awesome phacts");
        }
        $phacts = [];
        foreach ($phactsObjects as $key => $phact) {
            $category = $this->getPhactCategories($phact->id, $userId);
            $phact = get_object_vars($phact);
            $phact["color"] = $category["color"];
            $phact["categories"] = $category["categories"];
            $phacts[] = $phact;
        }
        return $phacts;
    }

    /**
     * @param $user_id
     * @param bool $category_id
     * @return array
     */
    public function getUserPhacts($user_id, $category_id = 0)
    {
        if ($category_id == 0) {
            $query = sprintf("
                SELECT phacts.* FROM %s as phacts
                LEFT JOIN %s as phacts_categories ON phacts_categories.phact_id = phacts.id
                    WHERE phacts_categories.id is null AND phacts.user_id = %d AND (phacts.status is null OR phacts.status != 'deleted')
                    GROUP BY phacts.id
                    ORDER BY phacts.date_created DESC limit 15",
                self::TABLE, CategoriesDB::PHACT_CATEGORIES_TABLE, $user_id);
            $stmt = $this->db->prepare($query);
            $stmt->execute();
            $phactsObjects = $stmt->fetchAll();

            $query = sprintf("
                SELECT phacts.* FROM %s as phacts
                LEFT JOIN %s as phacts_categories ON phacts_categories.phact_id = phacts.id
                    WHERE phacts_categories.id is null AND phacts.user_id = %d AND (phacts.status is null OR phacts.status != 'deleted')
                    GROUP BY phacts.id
                    ORDER BY phacts.date_created DESC limit 15, 15",
                self::TABLE, CategoriesDB::PHACT_CATEGORIES_TABLE, $user_id);
            $stmt = $this->db->prepare($query);
            $stmt->execute();
            array_push($phactsObjects, $stmt->fetchAll());

            $query = sprintf("
                SELECT phacts.* FROM %s as phacts
                LEFT JOIN %s as phacts_categories ON phacts_categories.phact_id = phacts.id
                    WHERE phacts_categories.id is null AND phacts.user_id = %d AND (phacts.status is null OR phacts.status != 'deleted')
                    GROUP BY phacts.id
                    ORDER BY phacts.date_created DESC limit 30, 15",
                self::TABLE, CategoriesDB::PHACT_CATEGORIES_TABLE, $user_id);
            $stmt = $this->db->prepare($query);
            $stmt->execute();
            array_push($phactsObjects, $stmt->fetchAll());

        } else {
            $query = sprintf("
                SELECT phacts.* FROM %s as phacts
                INNER JOIN %s as phacts_categories ON phacts_categories.phact_id = phacts.id
                    AND phacts_categories.category_id = %d
                    WHERE phacts_categories.user_id = %d AND (phacts.status is null OR phacts.status != 'deleted' OR phacts.user_id != %d)
                    GROUP BY phacts.id
                    ORDER BY phacts.date_created DESC",
                self::TABLE, CategoriesDB::PHACT_CATEGORIES_TABLE, $category_id, $user_id, $user_id);
//            die($query);
            $stmt = $this->db->prepare($query);
            $stmt->execute();
            $phactsObjects = $stmt->fetchAll();
        }
        if (!$phactsObjects or !count($phactsObjects)) {
            throw new Exception("You have no saved phacts, go ahead and create awesome phacts ");
        }
        $phacts = [];
        foreach ($phactsObjects as $key => $phact) {
            $category = $this->getPhactCategories($phact->id, $user_id);
            $phact = get_object_vars($phact);
            $phact["color"] = $category["color"];
            $phact["categories"] = $category["categories"];
            $phacts[] = $phact;
        }
        return $phacts;
    }

    public function delete($phact_id)
    {
//        $this->db->delete(self::)
        $this->db->delete(self::TABLE, $this->map, ["id" => $phact_id]);
    }


    public function isInFeed($phact_id)
    {
        return (bool)$this->db->read(self::FEED_TABLE, $this->feed_table, [], ["phact_id" => $phact_id]);
    }


}

?>