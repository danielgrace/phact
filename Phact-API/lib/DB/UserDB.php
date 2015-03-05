<?php
class UserDB extends DB
{
    const TABLE = 't_users';
    private $map = array(
        'id'                            => array(PDO::PARAM_INT, 10),
        'usr_fname'                     => array(PDO::PARAM_STR, 50),
        'usr_lname'                     => array(PDO::PARAM_STR, 50),
        'usr_pass'                      => array(PDO::PARAM_STR, 4),
        'usr_email'                     => array(PDO::PARAM_STR, 100),
        'usr_dob'                       => array(PDO::PARAM_STR, 10),
        'usr_avatar'                    => array(PDO::PARAM_STR, 250),
        'usr_country'                   => array(PDO::PARAM_STR, 2),
        'usr_date_created'              => array(PDO::PARAM_STR),
        'status'                        => array(PDO::PARAM_STR),
        'reset_pass_hash'               => array(PDO::PARAM_STR, 100),
    );








    public function setStatus($status, $phoneNumber)
    {
        return $this->db->update(
            self::TABLE,
            $this->map,
            array('status' => $status),
            array('usr_id' => $phoneNumber)
        );
    }

    public function get($what, $where)
    {
        return $this->db->read(
            self::TABLE,
            $this->map,
            $what,
            $where
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
        $id = $this->db->lastInsertId();
        //give user default philters
        $insertDefaultPhilters = "insert into user_philters (user_id, philter_id, status) select ".$id.", id, status from philters where is_default = 1";
        $stmt = $this->db->prepare($insertDefaultPhilters);
        $stmt->execute();
        return $id;

    }

    public function setUserAvatar($userId, $avatar) {
        return $this->set(["usr_avatar"=>$avatar], ["id"=>$userId]);
    }

}
?>