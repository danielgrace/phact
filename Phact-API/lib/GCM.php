<?php
/**
 * Class for sending push notifications
 * to Android devices using
 * GCM (Google Cloud Messaging)
 *
 * @author Garik G <garik@bigbek.com>
 */
class GCM
{
    /**
     * @var resource - curl handle
     */
    private $curl;

    /**
     * @var array - message data array
     */
    private $msg = array();

    /**
     * @var array - registration ids
     */
    private $regIds = array();

    /**
     * @var array - chunks array to break
     * notifications to
     */
    private $chunks = array();

    /**
     * @var Config - Config object
     */
    private $config;

    /**
     * By default GCM allows sending
     * 1000 notifications at once
     */
    const CHUNK_SIZE = 1000;

    /**
     * Constructor, starts curl session
     *
     * @param Config $config
     */
    public function __construct(Config $config)
    {
        $this->curl = curl_init();
        $this->config = $config;
    }

    /**
     * Queue registration ids
     * and message
     *
     * @array $params - push notification
     * sending options
     * @bool $sandbox - sandbox mode
     * @throws Exception
     */
    public function queue($params, $sandbox = false)
    {
        if (!isset($params['token'])) {
            throw new Exception('Please provide GCM registration_id');
        }

        if (count($this->regIds) >= self::CHUNK_SIZE) {
            $this->chunks[] = $this->regIds;
            $this->regIds = array();
        }

        array_push($this->regIds, $params['token']);

        if (empty($this->msg)) {
            unset($params['token']);

            if ($sandbox === true) {
                $this->msg['dry_run'] = true;
            }

            $this->msg['data'] = $params;
        }
    }

    /**
     * Sends notifications chunk by chunk
     *
     * @return array - array of responses by chunk
     * @throws Exception
     */
    public function send()
    {
        $this->chunks[] = $this->regIds;
        $responses = array();

        foreach ($this->chunks as $k => $chunk) {
            $this->chunks[$k] = array_merge(
                array('registration_ids' => $chunk),
                $this->msg
            );
        }

        $headers = array(
            'Authorization: key=' . $this->config->google->api->key,
            'Content-Type: application/json'
        );

        foreach ($this->chunks as $chunk) {
            $options = array(
                CURLOPT_URL             => $this->config->gcm->url,
                CURLOPT_POST            => true,
                CURLOPT_RETURNTRANSFER  => true,
                CURLOPT_HTTPHEADER      => $headers,
                CURLOPT_POSTFIELDS      => json_encode($chunk),
                CURLOPT_SSL_VERIFYPEER  => false
            );

            curl_setopt_array($this->curl, $options);

            $response = curl_exec($this->curl);
            $info = curl_getinfo($this->curl);

            if ($info['http_code'] !== 200) {
                throw new Exception('Google API not authorized');
            } else {
                $responses[] = json_decode($response);
            }
        }

        return $responses;
    }

    /**
     * Destructor, closes curl session
     */
    public function __destruct()
    {
        curl_close($this->curl);
    }
}
?>