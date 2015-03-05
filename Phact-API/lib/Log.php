<?php

class Log
{

    private $queue;
    private $config;

    public function __construct(Config $config)
    {
        $this->config = $config;
    }

    public function info($type, $code, $message, $path = '')
    {
        $msg = date('d.m.Y H:i:s') . ' [' . $_SERVER['REMOTE_ADDR'] . "]\r\n";
        $msg .= $type . ':' . $code . ' ' . $message . "\r\n";
        $msg .= str_repeat('-', 70) . "\r\n";

        if ($path === '') {
            $path = $this->config->log->path->info;
        }

        error_log($msg, 3, $path);
    }

    public function warning($type, $code, $message, $path = '')
    {
        $log = $this->config->log;

        if (isset($log->$type) && $log->$type->warning->enabled === '1') {
            $msg = date('d.m.Y H:i:s') . ' [' . $_SERVER['REMOTE_ADDR'] . "]\r\n";
            $msg .= $type . ':' . $code . ' ' . $message . "\r\n";
            $msg .= str_repeat('-', 70) . "\r\n";

            if ($path === '') {
                $path = $this->config->log->path->warning;
            }

            error_log($msg, 3, $path);
        }
    }

}
?>