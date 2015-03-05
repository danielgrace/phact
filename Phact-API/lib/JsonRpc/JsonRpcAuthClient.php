<?php

/**
 * PHP implementation of JSON-RPC 2.0 client with Authentication
 *
 * Specification: http://www.jsonrpc.org/specification
 *
 * @package JsonRpcPhp
 * @author Garik G <garik@bigbek.com>
 */
class JsonRpcAuthClient extends JsonRpcClient
{

    /**
     *
     * @var mixed - Digest object
     */
    private $digest;

    /**
     *
     * @var mixed - Config object
     */
    private $config;

    /**
     *
     * @var string - Raw request header
     */
    private $requestHeader;

    /**
     *
     * @var string - Raw response header
     */
    private $responseHeader;

    /**
     *
     * @var mixed - array of authentication options
     */
    private $authOptions;

    /**
     * Constructor
     * Initializes cURL session
     *
     * @param $url string - JSON-RPC server url
     * @param HTTPDigestAuthClient $digest - HTTPDigestAuthClient object
     * @param Config $config - Config object
     */
    public function __construct($url, HTTPDigestAuthClient $digest, Config $config)
    {
        $this->curl = curl_init($url);
        $this->digest = $digest;
        $this->config = $config;

        $this->secret = $this->config->secret->key;
    }

    /**
     * Setter of authentication options
     *
     * @param string $key - auth option key
     * @param mixed $value - auth option value
     */
    public function __set($key, $value)
    {
        $this->authOptions[$key] = $value;
    }

    /**
     * Getter of authentication option
     *
     * @param string $key - auth option key
     * @return mixed - auth option value
     */
    public function __get($key)
    {
        return $this->authOptions[$key];
    }

    /**
     * Getter of authentication option
     *
     * @param string $key - auth option key
     * @return mixed - auth option value
     */
    public function __isset($key)
    {
        return isset($this->authOptions[$key]) ? true : false;
    }

    /**
     * Getter for raw request header
     *
     * @return string - request header
     */
    public function getRequestHeader()
    {
        return $this->requestHeader;
    }

    /**
     * Getter for raw response header
     *
     * @return string - response header
     */
    public function getResponseHeader()
    {
        return $this->responseHeader;
    }

    /**
     * Performs JSON-RPC authenticated raw call
     *
     * @param $request mixed - JSON-RPC Request
     * @throws Exception
     * @return string - JSON-RPC Response
     */
    public function rawcall($request)
    {
        $this->lastRequest = stripslashes($request);

        $authHeader = array($this->digest->createDigest($this->authOptions));
        $authHeader[] = 'User-Agent: ' . $this->ua;

        $options = array(
            CURLINFO_CONTENT_TYPE => "application/json",
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $request,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $authHeader,
            CURLINFO_HEADER_OUT => true,
            CURLOPT_HEADER => true,
            CURLOPT_SSL_VERIFYPEER => false
        );

        curl_setopt_array($this->curl, $options);

        $response = curl_exec($this->curl);
        $info = curl_getinfo($this->curl);
        $error = curl_error($this->curl);

        if (isset($info['request_header'])) {
            $this->requestHeader = $info['request_header'];
        }

        $this->responseHeader = $response;
        $response = substr($response, $info['header_size']);

        if ($error !== '') {
            $response = $error;
        } elseif ($info['http_code'] !== 200) {
            $response = '';
        }

        if ($response !== '') {
            return $response;
        }
    }

}
?>