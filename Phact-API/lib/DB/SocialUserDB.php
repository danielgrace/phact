<?php
class SocialUserDB extends DB
{
    const TABLE = 'social_users';
    private $map = array(
        'id' => array(PDO::PARAM_INT, 10),
        'user_id' => array(PDO::PARAM_INT),
        'first_name' => array(PDO::PARAM_STR, 50),
        'last_name' => array(PDO::PARAM_STR, 50),
        'picture' => array(PDO::PARAM_STR, 50),
        'location' => array(PDO::PARAM_STR, 2),
        'dob' => array(PDO::PARAM_STR, 10),
        'birthday' => array(PDO::PARAM_STR, 10),
        'email' => array(PDO::PARAM_STR, 100),
        'gender' => array(PDO::PARAM_STR, 100),
        'social_link' => array(PDO::PARAM_STR),
        'social_username' => array(PDO::PARAM_INT),
        'timezone' => array(PDO::PARAM_STR),
        'signup_source' => array(PDO::PARAM_STR, 10),
        'social_account_name' => array(PDO::PARAM_STR, 100),
        'social_account_vendor' => array(PDO::PARAM_STR, 100),
        'social_account_id' => array(PDO::PARAM_INT, 100),
        'social_access_token' => array(PDO::PARAM_INT, 255),
        'social_access_token_expiration_date' => array(PDO::PARAM_INT, 100),
        'created_on' => array(PDO::PARAM_INT, 100),
        'last_updated_on' => array(PDO::PARAM_INT, 100),
    );


    public function get($what, $where, $multi = false)
    {

        $multi = $multi ? PhactDB::FETCH_ALL : PhactDB::FETCH_SINGLE;

        return $this->db->read(
            self::TABLE,
            $this->map,
            $what,
            $where,
            $multi
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
    }



}

?>