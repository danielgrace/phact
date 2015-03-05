<?php
class HTTPDigestAuthException extends Exception
{
    private $messages = array(
        40100 => 'Invalid digest format: %s',
        40101 => 'Mandatory field(s) missing: %s',
        40102 => 'Unknown realm: %s',
        40103 => 'Unknown qop value: %s',
        40104 => 'Invalid opaque: %s',
        40105 => 'Unknown user: %s',
        40106 => 'Response mismatch: %s',
        40107 => 'Nonce count is the same'
    );
    
    public function __construct($message, $code = 0)
    {
        parent::__construct(sprintf($this->messages[$code], $message), $code);
    }
}
?>