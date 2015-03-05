<?php

/**
 * PhactAuth Exceptions
 */
class PhactAuthException extends Exception
{

    /**
     * Constructor
     *
     * @param string $message
     * @param int $code
     * @param array $params
     */
    public function __construct($message = '', $code = 0, $params = array())
    {
        if (!empty($params)) {
            $message = vsprintf($message, $params);
        }

        parent::__construct($message, $code);
    }

    /**
     * Get exception type
     *
     * @return string - type of exception
     */
    public function getType()
    {
        return 'auth';
    }

}

/**
 * Performs API auth request validation and
 * API authentication
 *
 * @author Garik G <garik@bigbek.com>
 */
class PhactAuth
{

    /**
     *
     * @var mixed - Config object
     */
    private $config;

    /**
     *
     * @var mixed Digest object
     */
    private $digest;

    /**
     *
     * @var mixed - PhactDB object
     */
    private $db;

    /**
     * Constructor
     *
     * @param Config $config - Config object
     * @param Digest $digest - Digest object
     * @param PhactDB $db - PhactDB object
     */
    public function __construct(Config $config, Digest $digest, PhactDB $db)
    {
        $this->config = $config;
        $this->digest = $digest;
        $this->db = $db;
    }

    /**
     * Performs authentication
     *
     * @param string $cDigest - request digest
     * @param string $ua - User Agent header
     * @throws PhactAuthException
     * @internal param string $version - app version
     * @return mixed - array of app name and user id
     */
    public function authenticate($cDigest, $ua)
    {
        $data = array();
        $result = array();

        $request = $this->parse($cDigest);
        list($app, $version) = $this->parseUA($ua);

        $this->validateKeys(array_keys($request));

        $result['app'] = $data['app'] = $app;
        $result['version'] = $data['version'] = $version;
        $data['secret'] = $this->config->secret->key;

        if (isset($request['uid'])) {
            $data['uid'] = $request['uid'];

            $userData = $this->getUserByHash($data['uid']);

            if ($userData === false) {
                $msg = 'Attempt to use unexisting uash: %s';
                throw new PhactAuthException($msg, 100, array($data['uid']));
            } else {
                $data['phone'] = $userData->phone;
                $data['udid'] = $userData->udid;
                $result = array_merge($result, (array)$userData);
                //$result['user_id'] = $userData->id;
            }
        }

        $data['apiKey'] = $this->getApiKey($app, $version);

        $response = $this->digest->calculate($data);

        if ($response !== $request['data']) {
            $msg = "Wrong credentials: \r\nRequest: %s\r\nApp: %s\r\nVersion: %s";
            throw new PhactAuthException($msg, 101, array($cDigest, $app, $version));
        }

        return $result;
    }

    /**
     * Get user data by uhash
     *
     * @param string $hash - user hash passed in request
     * @return mixed - PDOStatement object
     */
    private function getUserByHash($hash)
    {
        $query = 'SELECT id,
                  usr_udid as udid,
                  FROM t_users WHERE uhash=:uhash';

        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':uhash', $hash, PDO::PARAM_STR, 32);

        $stmt->execute();

        $result = $stmt->fetch();

        return $result;
    }

    /**
     * Parse request digest
     *
     * @param string $cDigest - request digest
     * @return mixed - associative array of keys and values
     * @throws PhactAuthException
     */
    public function parse($cDigest)
    {
        $matches = array();
        $pattern = '@([a-z]+)=\"([A-Za-z0-9]+)\"[,\s]?@';

        $data = preg_match_all($pattern, $cDigest, $matches);

        if ($data === 0) {
            $msg = "Parse error: Invalid digest header\r\n%s";
            throw new PhactAuthException($msg, 102, array($cDigest));
        }

        return array_combine($matches[1], $matches[2]);
    }

    /**
     * Parse User-Agent header
     *
     * @param string $ua - User-Agent header
     * @return array - array of parsed app name and version if present
     * @throws PhactAuthException
     */
    public function parseUA($ua)
    {
        $matches = array();

        $pattern = '/([A-Za-z]+)\s([\d\.]+)/';

        $result = preg_match($pattern, $ua, $matches);

        if ($result !== 1) {
            $msg = 'Parse error: Incorrect User-Agent header: %s';
            throw new PhactAuthException($msg, 103, array($ua));
        }

        return array_slice($matches, 1);
    }

    /**
     * Check if mandatory fields are set
     *
     * @param mixed $keys - array of fields to check
     * @throws PhactAuthException
     */
    public function validateKeys($keys)
    {
        if (in_array('data', $keys) === false) {
            $msg = 'Parse error: Mandatory field "data" not present';
            throw new PhactAuthException($msg, 104);
        }
    }

    /**
     * Get API key from Config object
     *
     * @param string $app - app name
     * @param string $version - app version
     * @return string - API key
     * @throws PhactAuthException
     */
    public function getApiKey($app, $version)
    {
        if (!isset($this->config->apikeys[$app . ':' . $version])) {
            throw new PhactAuthException('Unknown app/version: %s:%s', 105, array($app, $version));
        }

        return $this->config->apikeys[$app . ':' . $version];
    }

}
?>