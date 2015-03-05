<?php
/**
 * Class for handling third-party (non-API) requests
 * from Twilio, PayPal etc.
 */
class Action
{
    /**
     * @var mixed - IOC object
     */
    private $ioc;

    /**
     * Constructor
     *
     * @param $ioc - IOC object
     */
    public function __construct($ioc)
    {
        $this->ioc = $ioc;
    }
}
?>