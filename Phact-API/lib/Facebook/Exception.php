<?php

namespace Bigbek\Facebook;


/**
 * Thrown when an API call returns an exception.
 *
 *
 */
class Exception extends \ErrorException
{

    /**
     * The result from the API server that represents the exception information.
     */


    /**
     * Make a new API Exception with the given result.
     *
     * @param Array $result the result from the API server
     */
    public function __construct($result)
    {


        $msg = "Unknown Error";
        $code = 2002;
        if (is_array($result) && array_key_exists("error", $result) && is_array($result["error"]) && array_key_exists("message", $result["error"])) {
            if ($result["error"]["code"] == 200) {
                $msg = "Action requires publish action permissions";
                $code = 3003;
            } else {
                $msg = $result["error"]["message"];
            }
        }
        if (is_array($result) && array_key_exists("error", $result) && is_array($result["error"]) && array_key_exists("error_subcode", $result["error"])) {
            $errorCode = $result["error"]["code"];
            $subCode = array_key_exists("error_subcode", $result["error"]) ? $result["error"]["error_subcode"] : false;
            if ($errorCode == 10 or ($errorCode >= 200 and $errorCode <= 299)) {

                $msg = "OAuth error-" . $errorCode;
                $code = 2001;

            } elseif (in_array($errorCode, array(1, 2, 4, 17))) {
                $msg = "Server-side problem; app should retry after waiting, up to some app-defined threshold";
                $code = 2002;
            } elseif ($code == 100) {
                $msg = "Application error";
                $code = 2002;
            }

            if ($subCode == 458) {
                $msg = "User removed the app from user settings";
                $code = 2001;
            } elseif ($subCode == 459) {
                $msg = "User need to login in Facebook";
                $code = 2001;
            } elseif ($subCode == 463) {
                $msg = "Access token Expired";
                $code = 2001;
            } elseif ($subCode == 467) {
                $msg = "Invalid Access token";
                $code = 2001;
            } elseif ($subCode == 464) {
                $msg = "Unconfirmed User";
                $code = 2001;
            } elseif ($subCode == 460) {
                $msg = "Password Changed";
                $code = 2001;
            }
        } elseif (is_array($result) && array_key_exists("error", $result) && is_array($result["error"])
            && array_key_exists("error_code", $result["error"]) && array_key_exists("error_msg", $result["error"] )) {
            $code = $result["error"]["error_code"];
            $msg = $result["error"]["error_msg"];

        }
        parent::__construct($msg, $code);
    }

    /**
     * Return the associated result object returned by the API server.
     *
     * @returns Array the result from the API server
     */
    public function getResult()
    {
        return $this->result;
    }

    /**
     * Returns the associated type for the error. This will default to
     * 'Exception' when a type is not available.
     *
     * @return String
     */
    public function getType()
    {
        if (isset($this->result['error'])) {
            $error = $this->result['error'];
            if (is_string($error)) {
                // OAuth 2.0 Draft 10 style
                return $error;
            } else if (is_array($error)) {
                // OAuth 2.0 Draft 00 style
                if (isset($error['type'])) {
                    return $error['type'];
                }
            }
        }
        return 'Exception';
    }

    /**
     * To make debugging easier.
     *
     * @returns String the string representation of the error
     */
    public function __toString()
    {
        $str = $this->getType() . ': ';
        if ($this->code != 0) {
            $str .= $this->code . ': ';
        }
        return $str . $this->message;
    }

}