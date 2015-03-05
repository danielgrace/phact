<?php

/**
 * AVT service methods
 * general for all realms
 *
 * @package Service
 * @class PhactGeneral
 * @author Garik G <garik@bigbek.com>
 */
class PhactGeneral
{

    /**
     * @var PhactDB mixed - PhactDB object
     */
    private $db;

    /**
     * @var UserDB mixed - UserDB object
     */
    private $userDB;

    /**
     * @var IOC mixed - IOC object
     */
    private $ioc;

    /**
     * @var Config mixed - Config object
     */
    private $config;

    /**
     * @var string - customer service email
     */
    private $csEmail;

    /**
     * Constructor
     *
     * @param IOC $ioc - IOC object
     * @internal param \PhactDB $PhactDB - PhactDB object
     * @internal param \Config $config - Config object
     */
    public function __construct(IOC $ioc)
    {
        $this->ioc          = $ioc;

        $db                 = $ioc->resolve('PhactDB');
        $this->config       = $ioc->resolve('Config');

        $this->db           = $db;

        $this->userDB       = new UserDB($db);

        $this->csEmail      = $this->config->cs->email;
    }




}

?>