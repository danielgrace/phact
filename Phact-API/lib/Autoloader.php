<?php

/**
 * Classes autoloader
 *
 * @package General
 */
class Autoloader
{

    /**
     * Register callback
     *
     * @return mixed
     */
    public static function register()
    {
        return spl_autoload_register(array('Autoloader', 'load'));
    }

    /**
     * Class loader
     *
     * @param $className string - class name
     */
    public static function load($className)
    {
        $ext = '.php';

        $modules = array(
            'JsonRpc',
            'DB',
            'Service',
            'HTTPDigestAuth',
            'ImageSearch',
            'Facebook',
            'Twitter',
        );

        if (strpos($className, 'ApnsPHP') !== false) {
            $className = str_replace('_', DS, $className);
        }

        if (strpos($className, 'PayPal') !== false) {
            $className = str_replace('\\', DS, $className);
        }

        if (file_exists(LIBDIR . $className . $ext)) {
            include LIBDIR . $className . $ext;
        } else {
            foreach ($modules as $module) {
                $class = LIBDIR . $module . DS . $className . $ext;
                if (file_exists($class)) {
                    include $class;
                }
            }
        }

    }

}
?>