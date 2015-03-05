<?php
class ConfigDB extends DB
{
    const TABLE = 'configuration';

    private $map = array(
        'id'        => array(PDO::PARAM_INT, 11),
        'cname'     => array(PDO::PARAM_STR, 100),
        'cvalue'    => array(PDO::PARAM_STR, 100),
        'ccomment'  => array(PDO::PARAM_STR, 200)
    );

    public function get($key)
    {
        $result = $this->db->read(
            self::TABLE,
            $this->map,
            array('cvalue'),
            array('cname' => $key)
        );

        return $result->cvalue;
    }

    public function getAll($key)
    {
        $result = array();

        $data = $this->db->read(
            self::TABLE,
            $this->map,
            array('cvalue'),
            array('cname' => $key),
            PhactDB::FETCH_ALL
        );

        foreach ($data as $item) {
            $result[] = $item->cvalue;
        }

        return $result;
    }

    public function getAllLike($key)
    {
        $milestones = array();

        $query = 'SELECT cvalue
                  FROM ' . self::TABLE . '
                  WHERE cname LIKE :key';

        $stmt = $this->db->prepare($query);

        $key .= '%';

        $stmt->bindParam(':key', $key, PDO::PARAM_STR);

        $stmt->execute();

        $result = $stmt->fetchAll();

        if (!empty($result)) {
            foreach ($result as $item) {
                $milestones[] = (int)$item->cvalue;
            }
        }

        return $milestones;
    }
}
?>