<?php
$iocconfig = array(
    'GCM'                   => 'Config',
    'APNS'                  => 'Config',
    'HTTPDigestAuthClient'  => 'HTTPDigestAuth,Config',
    'HTTPDigestAuthServer'  => 'HTTPDigestAuth,HTTPDigestAuthDB,Config',
    'HTTPDigestAuthDB'      => 'PhactDB',
    'PrivateRealm'          => 'PhactDB,Config',
    'PublicRealm'           => 'Config',
    'CallDB'                => 'PhactDB',
    'PhactDB'                 => 'Config',
    'PortaDB'               => 'Config',
    'Log'                   => 'Config',
    'PortaAccount'          => 'PortaAuth,Config',
    'PortaCustomer'         => 'PortaAuth,Config',
    'PortaAuth'             => 'Config',
    'Config'                => array(null, array($config, Config::PARSE_OBJECT))
);
?>