<?php
include '../../global.php';
$config = $ioc->resolve('Config');

$deviceMap = array();
$methodsMap = array();

$serviceDir = LIBDIR . 'Service';
$classes = scandir($serviceDir);
unset($classes[0]);
unset($classes[1]);
$i = 0;
foreach ($classes as $class) {
    $class = substr($class, 0, strpos($class, '.'));
//    var_dump($class);exit;
    if (empty($class)) continue;

    $refClass = new ReflectionClass($class);
    $methods = $refClass->getMethods(ReflectionMethod::IS_PUBLIC);

    foreach ($methods as $method) {
        if ($method->name !== '__construct'
            && $method->class === $refClass->name)
        {
            $methodsMap[$i][$method->name] = array();

            $params = $method->getParameters();

            if (!empty($params)) {
                $methodsMap[$i][$method->name]['params'] = array();
                foreach ($params as $param) {
                    $paramType = null;

                    if ($param->getClass() !== null) {
                        $paramType = 'object';
                    } elseif ($param->isArray() === true) {
                        $paramType = 'array';
                    }

                    $methodsMap[$i][$method->name]['params'][] = array(
                        'name' => $param->name,
                        'type' => $paramType
                    );
                }
            }

            $methodsMap[$i][$method->name]['type'] = (strpos($method->class, 'Private') !== false) ? 1 : 0;
            $i++;
        }
    }
}

foreach ($config->apikeys as $k => $v) {
    $deviceMap[$k]['username'] = $k;
    $deviceMap[$k]['password'] = $v;
}

header('Content-Type: application/javascript');
?>
var methodsMap  = <?php echo json_encode(array_values($methodsMap)); ?>;
    deviceMap   = <?php echo json_encode($deviceMap); ?>;
    realms      = <?php echo json_encode(array_keys($config->digest->realms)); ?>