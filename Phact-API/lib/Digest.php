<?php
/**
 * Calculate and create digest string
 */
class Digest
{

    /**
     * @param array $data - data to perform digest calculation
     * @return string - data hash
     */
    public function calculate($data)
    {
        $digest = array(
            $data['apiKey'],
            $data['secret'],
            $data['app'],
            $data['version']
        );

        if (isset($data['udid'])) {
            $digest['udid'] = $data['udid'];
            $digest['phone'] = $data['phone'];
        }

        $digestData = implode(':', $digest);

        return hash('sha256', $digestData);
    }


    /**
     * @param array $data - data to perform digest calculation
     * @return string - digest string
     */
    public function response($data)
    {
        $digest = array();

        $digest['data'] = $this->calculate($data);

        if (isset($data['uid'])) {
            $digest['uid'] = $data['uid'];
        }

        foreach ($digest as $k => $v) {
            $digest[$k] = $k . '="' . $v . '"';
        }

        $result = implode(', ', $digest);

        return $result;
    }

}
?>