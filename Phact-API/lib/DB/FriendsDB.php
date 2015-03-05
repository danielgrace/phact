<?php
class FriendsDB extends DB
{
    const TABLE = 'friends';
    private $map = array(
        'id' => array(PDO::PARAM_INT, 10),
        'user_id' => array(PDO::PARAM_INT),
        'friend_user_id' => array(PDO::PARAM_INT, 100),
        'created_on' => array(PDO::PARAM_INT, 100),
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

    public function delete($where)
    {
        return $this->db->delete(
            self::TABLE,
            $this->map,
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

    public function create($data, $options = [])
    {
        $this->db->create(
            self::TABLE,
            $this->map,
            $data,
            $options
        );
        return $this->db->lastInsertId();
    }



}

?>