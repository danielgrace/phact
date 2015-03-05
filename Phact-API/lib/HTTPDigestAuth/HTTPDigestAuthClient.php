<?php
session_start();

class HTTPDigestAuthClient
{
    public $realm;
    public $username;
    public $password;
    public $qop = 'auth';
    public $method;
    public $uri;
    public $nc = 1;

    public $status = 0;
    public $serverDigest;

    private $digest;
    private $config;

    public function __construct(HTTPDigestAuth $digest, Config $config)
    {
        $this->digest = $digest;
        $this->config = $config;
    }

    public function parse($header)
    {
        $digest = '';

        $str = 'WWW-Authenticate: Digest ';
        $len = strlen($str);

        if (($start = strpos($header, $str)) !== false) {
            $finish = strpos($header, "\r\n", $start);
            $digestStr = substr($header, $start + $len , $finish - ($start + $len));
            $digest = $this->digest->parseDigest($digestStr);

            $this->validateMandatoryFields($digest);
        }

        return $digest;
    }

    public function validateMandatoryFields($digest)
    {
        $mandatory = array(
            'realm',
            'nonce',
            'qop',
            'opaque'
        );

        $diff = array_diff($mandatory, array_keys($digest));

        if (!empty($diff)) {
            $message = implode(', ', $diff);
            throw new HTTPDigestAuthException($message, 40107);
        }
    }

    public function login($username, $password)
    {
        $this->username = $username;
        $this->password = $password;

        $authHeader = array($this->createDigest($this->authOptions));
        $authHeader[] = 'User-Agent: AVTMobile 1.2.1 (iPhone Simulator; iPhone OS 6.1; en_US)';
        $options = array(
            CURLINFO_CONTENT_TYPE => "application/json",
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => 'asd=asd',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $authHeader,
            CURLINFO_HEADER_OUT => true,
            CURLOPT_HEADER => true
        );

        $options[CURLOPT_CAINFO] = 'C:/wamp/www/bigbek_avtapi/ssl/avtapi.crt';

        curl_setopt_array($this->curl, $options);

        $response = curl_exec($this->curl);
        $info = curl_getinfo($this->curl);
        $error = curl_error($this->curl);

        if (isset($info['request_header'])) {
            $this->requestHeader = $info['request_header'];
        }

        $this->responseHeader = $response;

        $response = substr($response, $info['header_size']);

        if ($info['http_code'] === 401) {
            $digest = $this->parse($this->responseHeader);

            if (isset($digest['stale']) && $digest['stale'] === 'TRUE') {
                $this->status = 2;
            } else {
                $this->status = 1;
            }

            $this->serverDigest = $digest;
        }

        if ($error !== '') {
            $response = $error;
        }

        return $response;
    }

    public function createDigest($options)
    {
        if ($this->serverDigest !== null) {
            $_SESSION['nonce'] = $this->serverDigest['nonce'];
            unset($_SESSION['nc']);
            $this->nc = 1;
            $realm = $this->serverDigest['realm'];
        } else {
            $realm = $options['realm'];
        }

        if (!isset($_SESSION['nonce'])) {
            $_SESSION['nonce'] = $this->digest->generateNonce();
        }

        if (!isset($_SESSION['nc'])) {
            $_SESSION['nc'] = $this->nc;
        } else {
            if ($this->serverDigest === null) {
                $_SESSION['nc']++;
            }
        }

        $hex = dechex($_SESSION['nc']);
        $nc = str_repeat('0', 8 - strlen($hex)) . $hex;

        $nonce = $_SESSION['nonce'];
        $cnonce = $this->digest->generateNonce();

        $digestOptions = new stdClass;

        $digestOptions->realm = $realm;
        $digestOptions->username = $options['username'];
        $digestOptions->password = $options['password'];
        $digestOptions->nonce = $nonce;
        $digestOptions->nc = $nc;
        $digestOptions->qop = $this->qop;
        $digestOptions->cnonce = $cnonce;
        $digestOptions->method = $options['method'];
        $digestOptions->uri = $options['uri'];

        $this->digest->setDigest($digestOptions);

        $digest = 'Authorization: Digest ';
        $digest .= 'username="' . $options['username'] . '", ';
        $digest .= 'realm="' . $realm . '", ';
        $digest .= 'nonce="' . $nonce . '", ';
        $digest .= 'uri="' . $options['uri'] . '", ';
        $digest .= 'qop=' . $this->qop . ', ';
        $digest .= 'nc=' . $nc . ', ';
        $digest .= 'cnonce="' . $cnonce . '", ';
        $digest .= 'response="' . $this->digest->createResponse() . '", ';
        $digest .= 'opaque="' . md5($realm) . '"';

        return $digest;
    }
}
?>