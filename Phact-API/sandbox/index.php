<?php
include '../global.php';

$config = $ioc->resolve('Config');

if (isset($_POST['host'])) {
    $url = $_POST['host'];
    $method = $_POST['method'];
    $params = (isset($_POST['params'])) ? $_POST['params'] : null;

    if ($params !== null) {
        foreach ($params as $k => $v) {
            if (strpos($v, '=') !== false && strpos($v, '==') === false) {
                parse_str($v, $data);
                $params[$k] = $data;
            } elseif (strpos($v, '&') !== false) {
                parse_str($v, $data);
                $params[$k] = array_keys($data);
            }
        }
    }

    $digest = $ioc->resolve('HTTPDigestAuthClient');
//    var_dump($url);
    $client = new JsonRpcAuthClient($url, $digest, $config);
//    die("here");
    switch ($_POST['username']) {
        case 'android':
            $ua = 'AVTMobile 1.0.0 (Desire HD; Android 2.3.3; en) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30';
            break;
        case 'iphone':
        default:
            $ua = 'AVTMobile 1.2.1 (iPhone Simulator; iPhone OS 6.1; en_US)';
            break;
    }

    $client->ua = $ua;

    $client->realm = $_POST['realm'];
    $client->username = $_POST['username'];
    $pwd = $_POST['password'];
    $client->method = $config->digest->method;
    $client->uri = $config->digest->uri;

    if (isset($_POST['open_udid'])) {
        $realmWrapper = $ioc->resolve('PrivateRealm');
        $openUdid = $_POST['open_udid'];
        $client->password = $realmWrapper->generatePwd($pwd);
    } else {
        $realmWrapper = $ioc->resolve('PublicRealm');
        $client->password = $realmWrapper->generatePwd($pwd);
    }

    $response = $client->$method($params, 1);



    $result['request'] = $client->getLastRequest();
    $result['requestHeader'] = $client->getRequestHeader() . $result['request'];
    $result['response'] = $response;
    $result['responseHeader'] = $client->getResponseHeader();

    echo json_encode($result);
    exit;
}

include 'index.tpl.html';
?>