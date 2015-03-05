<?php
class HTTPDigestAuth
{
    private $digest;

    public function __get($key)
    {
        return $this->digest->$key;
    }

    public function setDigest($digest)
    {
        $this->digest = $digest;
    }

    public function getDigest()
    {
        return $this->digest;
    }

    public function generateNonce()
    {
        return md5(time() . mt_rand(1000000, 9999999) . uniqid('', true));
    }

    public function parseDigest($digest)
    {
        $matches = array();

        $data = preg_match_all('/([a-z]+)=\"?([\w\/\.@-]+)[\",\s]?/', $digest, $matches);

        if ($data === 0) {
            throw new HTTPDigestAuthException($digest, 40100);
        }

        $result = array_combine(
            $matches[1],
            $matches[2]
        );
        
        return $result;
    }

    private function createA1()
    {
        return md5($this->username . ':' . $this->realm . ':' . $this->password);
    }

    private function createA2()
    {
        $a2 = '';

        if ($this->qop === 'auth') {
            $a2 = md5($this->method . ':' . $this->uri);
        }

        return $a2;
    }

    public function createResponse()
    {
        return md5(implode(':', array(
                $this->createA1(),
                $this->nonce,
                $this->nc,
                $this->cnonce,
                $this->qop,
                $this->createA2())
            )
        );                
    }
}
?>