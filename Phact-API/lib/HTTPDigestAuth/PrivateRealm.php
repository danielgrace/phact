<?php
class PrivateRealm implements IRealm
{
    private $db;
    private $config;

    public function __construct(PhactDB $db, Config $config)
    {
        $this->db = $db;
        $this->config = $config;
    }

    public function generatePwd($pin)
    {
        $secretKey = $this->config->secret->key;
        return sha1(implode(':', array($pin, $secretKey)));
    }

    public function getUser($username)
    {
        $query = 'SELECT * FROM t_users WHERE usr_email=:username';
        $stmt = $this->db->prepare($query);
        $stmt->bindParam(':username', $username, PDO::PARAM_INT);
        $stmt->execute();

        $result = $stmt->fetch();

        if ($result !== false) {
            $result->password = $this->generatePwd(
                $result->usr_pass
            );
        }

        return $result;
    }
}

?>