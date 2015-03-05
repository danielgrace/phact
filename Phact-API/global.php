<?php
date_default_timezone_set('UTC');

define('DS', DIRECTORY_SEPARATOR);
define('PS', PATH_SEPARATOR);
define('BASEDIR', dirname(__FILE__) . DS);
define('LIBDIR', BASEDIR . 'lib' . DS);

$config = parse_ini_file(BASEDIR . 'config.ini', true);
include LIBDIR . 'Autoloader.php';
Autoloader::register();

include BASEDIR . 'iocconfig.php';
include LIBDIR . 'JsonRpc/JsonRpcException.php';

$ioc = new IOC($iocconfig);
?>