<?php
class Facebook
{

    protected $_fbUrl = "https://graph.facebook.com/";
    protected $_access_token = "08efa52d5d6e33e83bf0c1709210c351";
    protected $_fbId = "224435767752567";

    public function __construct($config)
    {

    }

    public function setAccessToken($token) {
        $this->_access_token = $token;
    }

    public function getFriends($offset, $limit = 0)
    {
        $http = new HTTP();
        $limitStr = $limit === 0 ? '' : '.offset(' . $offset . ').limit(' . $limit . ')';
        $url = $this->_fbUrl . 'me/?access_token='
            . $this->_access_token
            . '&fields=id,name,friends.fields(installed,first_name,devices,last_name,gender,picture.width(200).height(200))' . $limitStr;
        $responseBody = $http->get($url, false, true);
        error_log(__METHOD__);
        error_log(var_export($responseBody, true));
//        var_dump($url);
        $responseBodyArray = json_decode($responseBody);
//        var_dump($responseBodyArray->friends);
        error_log(var_export($responseBodyArray, true));
        if (property_exists($responseBodyArray, "friends")) {
            return $responseBodyArray->friends;
        } else {
            error_log(var_export($responseBodyArray->error, true));
            if (property_exists($responseBodyArray, "error")) {
                if ((int) $responseBodyArray->error->code == 190) {

                    throw new Exception("Facebook session expired please login again");
                }
            }
            throw new Exception("User has no Friends");
        }
    }

//    public function sharePost($message, $picture, $link, $name)
//    {
//        $httpClient = new \Zend_Http_Client($this->_fbUrl . 'me/feed?access_token=' . $this->_access_token,
//            array(
//                'maxredirects' => 0,
//                'timeout' => 30));
//        $httpClient->setParameterPost('message', $message);
//        $httpClient->setParameterPost('picture', $picture);
//        $httpClient->setParameterPost('link', $link);
//        $httpClient->setParameterPost('caption', $name);
//        $httpClient->setParameterPost('name', $name);
//        $httpClient->setParameterPost('privacy', "{'value':'SELF'}");
//
//        $responseBody = $httpClient->request(\Zend_Http_Client::POST)->getBody();
//        $responseBodyArray = \Zend_Json::decode($responseBody);
//        if (isset($responseBodyArray['id'])) {
//            return $responseBodyArray['id'];
//        } else {
//            throw new \Bigbek\Facebook\Exception($responseBodyArray);
//        }
//    }

    public function getInfo($fields = false)
    {
        if ($fields) {
            if (is_array($fields)) {
                $picKey = array_search("picture", $fields);
                if ($picKey) {
                    $fields[$picKey] = "picture.width(200).height(200)";
                }
                $fieldsString = implode(",", $fields);
            } elseif ($fields == "picture") {
                $fieldsString = "picture.width(200).height(200)";
            } else {
                $fieldsString = $fields;
            }
        } else {
            $fieldsString = "id,first_name,last_name,gender,email,location,birthday,picture.width(200).height(200)";

        }

        $httpClient = new \Zend_Http_Client($this->_fbUrl . 'me/?access_token=' . $this->_access_token . '&fields='.$fieldsString,
            array(
                'maxredirects' => 0,
                'timeout' => 30));
        $responseBody = $httpClient->request()->getBody();
        $responseBodyArray = \Zend_Json::decode($responseBody);
        if (is_array($responseBodyArray)) {
            return $responseBodyArray;
        } else {
            throw new \Bigbek\Facebook\Exception($responseBodyArray);
        }
    }

//    public function follow($followingID)
//    {
//        $httpClient = new \Zend_Http_Client($this->_fbUrl .'me/og.follows?access_token=' . $this->_access_token,
//            array(
//                'maxredirects' => 0,
//                'timeout' => 30));
//        $httpClient->setParameterPost('profile', $followingID);
//        $responseBody = $httpClient->request(\Zend_Http_Client::POST)->getBody();
//
//        $responseBodyArray = \Zend_Json::decode($responseBody);
//
//        if (isset($responseBodyArray['id'])) {
//            return $responseBodyArray['id'];
//        } else {
//            throw new \Bigbek\Facebook\Exception($responseBodyArray);
//
//        }
//    }

//    public function makeSnbOpenGraphAction($action, $item, $message = "", $explicitSharing = false)
//    {
//        $httpClient = new \Zend_Http_Client($this->_fbUrl . 'me/shopnbrag:' . $action . '?access_token=' . $this->_access_token,
//            array(
//                'maxredirects' => 0,
//                'timeout' => 30));
//        $httpClient->setParameterPost('item', $item);
//        if ($explicitSharing) {
//            $httpClient->setParameterPost('fb:explicitly_shared', "true");
//        }
//        if (strlen($message)) {
//            $httpClient->setParameterPost('message', $message);
//        }
//
//        $responseBody = $httpClient->request(\Zend_Http_Client::POST)->getBody();
//
//        $responseBodyArray = \Zend_Json::decode($responseBody);
//        if (isset($responseBodyArray['id'])) {
//            return $responseBodyArray['id'];
//        } else {
//            throw new \Bigbek\Facebook\Exception($responseBodyArray);
//
//        }
//    }
//
//    public function deleteGraphAction($actionID) {
//        $httpClient = new \Zend_Http_Client($this->_fbUrl . '' . $actionID . '?access_token=' . $this->_access_token,
//            array(
//                'maxredirects' => 0,
//                'timeout' => 30));
//        $responseBody = $httpClient->request(\Zend_Http_Client::DELETE)->getBody();
//        $logger = \Zend_Registry::get("logger");
//        $logger->log(__METHOD__, \Zend_Log::DEBUG);
//        $logger->log(var_export($actionID, true), \Zend_Log::DEBUG);
//        $logger->log(var_export($this->_access_token, true), \Zend_Log::DEBUG);
//        $responseBodyArray = (array) json_decode($responseBody);
//        $logger->log(var_export($responseBodyArray, true), \Zend_Log::DEBUG);
//        if (isset($responseBodyArray['id'])) {
//            return $responseBodyArray['id'];
//        } else {
//            throw new \Bigbek\Facebook\Exception($responseBodyArray);
//
//        }
//
//    }

    public function getFbId()
    {
        return $this->_fbId;
    }


    public function sendCurl($url, $isPost = false) {

        $curl = curl_init();
        curl_setopt ($curl, CURLOPT_URL, $url);
//        curl_setopt ($curl, CURLOPT_USERAGENT, $this->user_agent);
        curl_setopt ($curl, CURLOPT_HEADER, 0);
        curl_setopt ($curl, CURLOPT_FOLLOWLOCATION, 1);
        curl_setopt ($curl, CURLOPT_RETURNTRANSFER, 1);
//        curl_setopt ($curl, CURLOPT_REFERER, $this->google);
        curl_setopt ($curl, CURLOPT_CONNECTTIMEOUT,120);
        curl_setopt ($curl, CURLOPT_TIMEOUT,120);
        curl_setopt ($curl, CURLOPT_MAXREDIRS,2);
        $searched = curl_exec($curl);
        curl_close ($curl);

        return $searched;
    }

}