<?php
class HTTP
{
    private $curl;
    
    public function __construct()
    {
        $this->curl = curl_init();
    }
    
    public function get($url, $sslVerifyPeer = true, $returnError = true)
    {
        $options = array(
            CURLOPT_URL     => $url,
            CURLOPT_HTTPGET => true,
            CURLOPT_RETURNTRANSFER => true
        );

        if ($sslVerifyPeer === false) {
            $options[CURLOPT_SSL_VERIFYPEER] = false;
        }

        curl_setopt_array($this->curl, $options);

        $response = curl_exec($this->curl);
        $info = curl_getinfo($this->curl);


        if ($info['http_code'] === 200) {
            return $response;
        } else {
            if ($returnError) {
                return $response;
            } else {
                return '';
            }
        }
    }

    public function post($url, $data, $sslVerifyPeer = true)
    {
        $options = array(
            CURLOPT_URL             => $url,
            CURLOPT_POST            => true,
            CURLOPT_RETURNTRANSFER  => true,
            CURLOPT_POSTFIELDS      => $data
        );

        if ($sslVerifyPeer === false) {
            $options[CURLOPT_SSL_VERIFYPEER] = false;
        }

        curl_setopt_array($this->curl, $options);

        $response = curl_exec($this->curl);
        $info = curl_getinfo($this->curl);

        return ($info['http_code'] === 200)
            ? $response
            : '';
    }
    
    public function __destruct()
    {
        curl_close($this->curl);
    }    
}
?>