<?php
class PublicRealm implements IRealm
{
    private $config;

    public function __construct(Config $config)
    {
        $this->config = $config;
    }

    public function generatePwd($apiKey)
    {
        $secretKey = $this->config->secret->key;
        return sha1(implode(':', array($apiKey, $secretKey)));
    }

    public function getUser($username)
    {
        $result = false;

        $users = $this->config->apikeys;

        if (isset($users[$username])) {
            $result = new stdClass();

            $password = $this->generatePwd($users[$username]);

            $result->username = $username;
            $result->password = $password;
        }

        return $result;
    }
}

?>