<?php
error_reporting(0);
include 'global.php';

$scriptTimeStart = microtime(true);
$config = $ioc->resolve('Config');

define('SSLDIR', $config->ssldir);

$log = $ioc->resolve('Log');

try {

    if (isset($_SERVER['HTTP_USER_AGENT'])) {
        $ua = $_SERVER['HTTP_USER_AGENT'];
        $appData = Util::extractAppData($ua);
    }

    $uri = trim($config->request->uri, '/');

    if ($uri !== '' && strpos($uri, 'favicon') === false) {
        try {
            $router = new Router($ioc, $uri);
            $router->run();
        } catch (Exception $e) {
            $code = $e->getCode();
            $log->warning('action', $code, $e->getMessage());

            switch ($code) {
                case 404:
                    header('HTTP/1.1 404 Not Found');
                    break;
                case 422:
                default:
                    header('HTTP/1.1 422 Unprocessable Entity');
                    break;
            }
        }
    } else {

        $auth = $ioc->resolve('HTTPDigestAuthServer');

        if (!isset($appData)) {
            throw new Exception('User Agent header not present', 90);
        }

        foreach ($config->digest->realms as $realm => $className) {
            $auth->realms[$realm] = $ioc->resolve($className);
        }

        $user = null;

        if (!isset($_SERVER['PHP_AUTH_DIGEST'])) {
            $realmType = (int)isset($_POST['private']);

            $realms = array_keys($config->digest->realms);
            $realm = $realms[$realmType];
            $auth->challenge($realm);

//            $log->info('realm', 100, "\r\n" . $realmType);
//            $log->info('post', 100, "\r\n" . var_export($_POST, true));
        } else {
            $user = $auth->process($_SERVER['PHP_AUTH_DIGEST']);
//            $log->info('user', 100, "\r\n" . var_export($user, true));
        }
        if ($user !== null) {

            $request = file_get_contents("php://input");

            $headers = apache_request_headers();
            $headerStr = "\r\n";

            foreach ($headers as $k => $header) {
                $headerStr .= $k . '=' . $header . "\r\n";
            }

//            $log->info('test', 100, $headerStr . "\r\n" . $request);

            if ($request !== '' && $request !== 'private=') {
                $server = new JsonRpcServer();
                if ($user->realm === 'user@api.phact.com') {
                    $private = new PhactPrivate($ioc, $appData, $user);
                    $server->addService($private);
                    $public = new Phact($ioc, $appData);
                    $server->addService($public);
                } else {
                    $phact = new Phact($ioc, $appData);
                    $server->addService($phact);
                }

                $result = $server->process($request);

//                $log->info('result', 100, "\r\n" . $result);

                header('Content-type: application/json');
                $scriptTimeEnd = microtime(true);
                $scriptTimeRaw = $scriptTimeEnd - $scriptTimeStart;
                $scriptTime = number_format($scriptTimeRaw, 2, ',', '.');
                $db = $ioc->resolve('PhactDB');
                $logArray = array();
//              var_dump($user);exit;
//              $logArray["user"] = json_decode(json_encode($user));

                $logArray["user"] = @$user->username;

                $method = json_decode($request);
                $logArray["method"] = $method->method;
                $logArray["api_version"] = 'v1';
                $logArray["request"] = $request;
                $logArray["request_header"] = implode(",", getallheaders());
                $logArray["response"] = json_encode($result);
                $logArray["response_time"] = $scriptTimeRaw;
                $logArray["app_version"] = $appData->version;
                $logArray["app_data"] = $appData->device;
                $db->logRequest($logArray);
                if ($result !== null) {

                    echo $result;
                }
            }
        }
    }
} catch (HTTPDigestAuthException $e) {
    $message = 'Digest: ' . $_SERVER['PHP_AUTH_DIGEST'] . "\r\n";

    if (isset($_SERVER['HTTP_USER_AGENT'])) {
        $message .= 'User-Agent: ' . $_SERVER['HTTP_USER_AGENT'] . "\r\n";
    }

    $message .= $e->getMessage();
    $log->warning('auth', $e->getCode(), $message);
    header('HTTP/1.1 403 Forbidden');
    echo json_encode(array("error"=>array(
//        "message"=>$message,
//        "mehtod"=>$method,
        "code"=>403,
        "data"=>"Your session has expired.")));
//    exit;
} catch (Exception $e) {
//    var_dump($e);
    $log->warning('avtgeneral', $e->getCode(), $e->getMessage());
    echo json_encode(array(
            "error" => array(
                "message" => $e->getMessage(),
                "code" => $e->getCode(),
                "data" => "Something went wrong, please try again.")
        )
    );
}
?>