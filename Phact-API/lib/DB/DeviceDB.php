<?php
class DeviceDB extends DB
{
    const TABLE = 'devices';

    private $map = array(
        'id'                        => array(PDO::PARAM_INT, 11),
        'name'               => array(PDO::PARAM_STR, 100),
        'open_udid'          => array(PDO::PARAM_INT, 100),
        'user_id'     => array(PDO::PARAM_STR, 10),
        'os_version'    => array(PDO::PARAM_STR, 100),
        'ip'         => array(PDO::PARAM_STR, 100),
        'mac'        => array(PDO::PARAM_STR, 100),
        'created_timestamp'         => array(PDO::PARAM_STR)
    );

    public static $convMap = array(
        'device_name'    => 'name',
        'open_udid'      => 'open_udid',
        'os_version'     => 'os_version',
        'ip'            => 'ip',
        'mac'           => 'mac'
    );

    public function create($data)
    {
        $result = $this->db->create(
            self::TABLE,
            $this->map,
            $data,
            array(
                'duplicate' => array(
                    'name' => $data['deviceName'],
                    'ip' => $data['ip'],
                    'mac' => $data['mac']
                )
            )
        );

        return $result->rowCount();
    }

    public function getByOpenUdid($what, $openUdid)
    {
        return $this->db->read(
            self::TABLE,
            $this->map,
            $what,
            array('open_udid' => $openUdid)
        );
    }

    public function connectToUser($userId, $openUdid) {
        return $this->db->update(self::TABLE, $this->map, array("user_id"=>$userId), array("open_udid"=>$openUdid));
    }

    public function update($what, $where) {
        return $this->db->update(self::TABLE, $this->map, $what, $where);
    }

    public function checkDevice($openUdid, $userId) {
        $deviceExists = $this->getByOpenUdid(array(), $openUdid);
        if ($deviceExists === false) {
            $deviceArray = array("open_udid" => $openUdid, "user_id" => $userId);
            $this->create($deviceArray);
        } elseif ($deviceExists && $deviceExists->user_id != $userId) {
            $this->connectToUser($userId, $openUdid);
        }
        return true;
    }

    public function getUserDevices($userID) {
        return $this->db->read(
            self::TABLE,
            $this->map,
            [],
            ['user_id' => $userID],
            PhactDB::FETCH_ALL
        );
    }
}
?>