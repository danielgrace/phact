<?php
class AddressBookDB extends DB
{
    const TABLE = 'address_book';
    private $map = array(
        'id' => array(PDO::PARAM_INT, 10),
        'user_id' => array(PDO::PARAM_INT),
        'email' => array(PDO::PARAM_STR, 200),
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

    public function create($data)
    {
        $this->db->create(
            self::TABLE,
            $this->map,
            $data
        );
        return $this->db->lastInsertId();
    }



}

?>