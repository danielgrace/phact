<?php
class PhilterDB extends DB
{
    const TABLE         = 'philters';
    const USER_REF_TABLE       = 'user_philters';

    private $rulesMap = array(
        'id'              => array(PDO::PARAM_INT, 11),
        'philter'      => array(PDO::PARAM_STR, 16),
        'is_default'      => array(PDO::PARAM_INT, 1),
        'status'      => array(PDO::PARAM_STR, 100)
    );

    private $userRefMap = array(
        'id'                => array(PDO::PARAM_INT, 11),
        'user_id'              => array(PDO::PARAM_INT, 11),
        'philter_id'            => array(PDO::PARAM_INT, 11),
        'status'   => array(PDO::PARAM_STR, 30)
    );

    public static $philterStatuses = array(
        'accepted',
        'canceled',
        'finished',
        'waiting'
    );

    public function get($what, $where, $one = true)
    {
        if ($one) {
            $flag = PhactDB::FETCH_SINGLE;
        } else {
            $flag = PhactDB::FETCH_ALL;

        }
        return $this->db->read(
            self::TABLE,
            $this->map,
            $what,
            $where,
            $flag
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
        error_log(var_export($data, true));
        $this->db->create(
            self::TABLE,
            $this->map,
            $data
        );
        return $this->db->lastInsertId();

    }

    public function updatePhilters($userID, $active, $passive) {
        $activeToSave = array();
        if (count($active)) {
            foreach ($active as $name) {
                $name = strtolower($name);
                $philterObject = $this->get(array("id"), array("philter"=>$name));
                if ($philterObject) {
                    $activeToSave[] = $philterObject->id;
                } else {
                    $activeToSave[] = $this->create(array("philter"=>$name));
                }
            }
            $active = $activeToSave;
        }
        if (count($passive)) {
            $passiveToSave = array();
            foreach ($passive as $name) {
                $name = strtolower($name);
                $philterObject = $this->get(array("id"), array("philter"=>$name));
                if ($philterObject) {
                    $passiveToSave[] = $philterObject->id;
                } else {
                    $passiveToSave[] = $this->create(array("philter"=>$name));
                }
            }
            $passive = $passiveToSave;
        }

        $query = "delete from `".self::USER_REF_TABLE."` where user_id = :user";
        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':user', $userID, PDO::PARAM_INT, 11);
        $stmt->execute();

        if(is_array($active) and count($active)) {

            $query = "insert into `".self::USER_REF_TABLE."` (user_id, philter_id, status) values ";
            foreach ($active as $p) {
                $query .= "(".$userID.",".$p .", 'active'),";
            }
            $query = substr($query, 0, -1);
            $stmt = $this->db->prepare($query);
            $stmt->execute();
        }

        if(is_array($passive) and count($passive)) {

            $query = "insert into `".self::USER_REF_TABLE."` (user_id, philter_id, status) values ";
            foreach ($passive as $p) {
                $query .= "(".$userID.",".$p .", 'passive'),";
            }
            $query = substr($query, 0, -1);
            $stmt = $this->db->prepare($query);
            $stmt->execute();
        }



    }

    public function getUserPhilters($userID, $onlyActives = false) {


        $query = "select * from `".self::TABLE."`
            inner join `".self::USER_REF_TABLE."` on `".
            self::TABLE."`.`id` = `".self::USER_REF_TABLE."`.`philter_id`
            WHERE `".self::USER_REF_TABLE."`.`user_id` = :user order by `".self::USER_REF_TABLE."`.`id`";
        if ($onlyActives) {
            $query .= " AND ".self::USER_REF_TABLE.".status = 'active'";
        }
        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':user', $userID, PDO::PARAM_INT, 11);

        $stmt->execute();

        $result = $stmt->fetchAll();
        return $result;
    }



}
?>