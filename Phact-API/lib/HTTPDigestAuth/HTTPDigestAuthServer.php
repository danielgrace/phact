<?php
class HTTPDigestAuthServer
{
    public $realms;
    public $qopList = array('auth');

    private $method;
    private $uri;

    private $authDB;
    private $digest;
    private $config;

    public function __construct(
        HTTPDigestAuth $digest,
        HTTPDigestAuthDB $authDB,
        Config $config
    )
    {
        $this->authDB = $authDB;
        $this->digest = $digest;
        $this->config = $config;

        $this->method = $this->config->digest->method;
        $this->uri = $this->config->digest->uri;
//        var_dump($this);
    }

    public function challenge($realm = null, $stale = false)
    {
        if ($realm === null) {
            $realms = array_keys($this->realms);
            $realm = $realms[0];
        }

        $nonce = $this->digest->generateNonce();

        $digest = 'realm="' . $realm . '", ';
        $digest .= 'nonce="' . $nonce . '", ';

        if ($stale === true) {
            $digest .= 'stale=TRUE, ';
        }

        $digest .= 'opaque="' . md5($realm) . '", ';
        $digest .= 'qop="' . implode(',', $this->qopList) . '"';

        header('HTTP/1.1 401 Unauthorized');
        header('WWW-Authenticate: Digest ' . $digest);

        return $nonce;
    }

    public function process($digestResponse, $uri = false)
    {
        $digest = $this->digest->parseDigest($digestResponse);
        $this->validateMandatoryFields($digest);

        $realm      = $digest['realm'];
        $nonce      = $digest['nonce'];
        $qop        = $digest['qop'];
        $username   = $digest['username'];
        $response   = $digest['response'];
        $opaque     = $digest['opaque'];
        $nc         = $digest['nc'];

        $this->validateRealm($realm);
        $this->validateQop($qop);
        $this->validateOpaque($realm, $opaque);

        $user = $this->getUser($realm, $username);

        $user->realm = $realm;

        $digest['method'] = $this->method;
        $digest['uri'] = $uri ? $uri : $this->uri;
//        $digest['uri'] = $this->uri;
        $digest['password'] = $user->password;

        $this->digest->setDigest((object)$digest);

        $this->validateResponse($response);

        $dbData = $this->authDB->read($nonce);

        if ($dbData !== false) {
//            $this->validateNonceCount($nc, $dbData->nc);

            if ($dbData->datediff > $this->config->digest->expiry) {
                $newnonce = $this->challenge($realm, true);
                $this->authDB->update($nonce, $newnonce);
            } else {
                $this->authDB->increaseUsage($nonce);
            }
        } else {
            $this->authDB->create($nonce);
        }

        return $user;
    }

    public function validateMandatoryFields($digest)
    {
        $mandatory = array(
            'realm',
            'nonce',
            'nc',
            'cnonce',
            'qop',
            'username',
            'uri',
            'response',
            'opaque'
        );

        $diff = array_diff($mandatory, array_keys($digest));
//var_dump($diff);exit;
        if (!empty($diff)) {
            $message = implode(', ', $diff);
            throw new HTTPDigestAuthException($message, 40110);
        }
    }

    public function validateRealm($realm)
    {
        if (!in_array($realm, array_keys($this->realms))) {
            throw new HTTPDigestAuthException($realm, 40102);
        }
    }

    public function validateQop($qop)
    {
        if (!in_array($qop, $this->qopList)) {
            throw new HTTPDigestAuthException($qop, 40103);
        }
    }

    public function validateOpaque($realm, $opaque)
    {
        if ($opaque !== md5($realm)) {
            throw new HTTPDigestAuthException($opaque, 40104);
        }
    }

    public function getUser($realm, $username)
    {
        $realmWrapper = $this->realms[$realm];

        if (($user = $realmWrapper->getUser($username)) === false) {
            throw new HTTPDigestAuthException($username, 40105);
        } else {
            return $user;
        }
    }

    public function validateResponse($cresponse)
    {
        $response = $this->digest->createResponse();

        if ($response !== $cresponse) {
            $message = 'Calculated - ' . $response . '; ';
            $message .= 'Received - ' . $cresponse . "\r\n";
            $message .= 'Server parameters: ' . print_r($this->digest->getDigest(), true);
            throw new HTTPDigestAuthException($message, 40106);
        }
    }

    public function validateNonceCount($nc, $dbNc)
    {
        if (hexdec($nc) === (int)($dbNc)) {
            throw new HTTPDigestAuthException('', 40107);
        }
    }
}
?>