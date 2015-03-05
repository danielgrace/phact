<?php
class APNS
{
    private $apns;
    
    public function __construct(Config $config)
    {
        $apnsOptions = $config->apns;

        $this->apns = new ApnsPHP_Push(
            $apnsOptions->env,
            $apnsOptions->certfile
        );

        $this->apns->setRootCertificationAuthority(
            $apnsOptions->rootcertfile
        );
        error_log("APNS");
    error_log($apnsOptions->rootcertfile);
    error_log($apnsOptions->certfile);
    error_log($apnsOptions->env);
        $this->apns->connect();
    }

    public function queue($params)
    {
        $msg = new ApnsPHP_Message($params['token']);

        $msg->setText($params['message']);
        $msg->setBadge((int)$params['badge']);
        $msg->setSound();

        if (array_key_exists('sound', $params)) {
            $msg->setSound($params['sound']);
        }

        if (array_key_exists('custom', $params)) {
            foreach ($params['custom'] as $custom) {
                $msg->setCustomProperty(
                    $custom['name'],
                    $custom['value']
                );
            }
        }

        $this->apns->add($msg);
    }

    public function send()
    {
        $this->apns->send();
        $this->apns->disconnect();
    }
}
?>