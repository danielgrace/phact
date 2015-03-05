<?php
class PhactException extends Exception
{
    public static $codes = array(
        100 =>
        PhactMsg::ACC_INACTIVE,
        PhactMsg::ACC_LIMIT_EXCEEDED,
        PhactMsg::DID_NOT_FOUND,
        PhactMsg::DUPLICATE_PROMO,
        PhactMsg::EMPTY_APNS_TOKEN,
        PhactMsg::EMPTY_IP,
        PhactMsg::EMPTY_OPEN_UDID,
        PhactMsg::EMPTY_UDID,
        PhactMsg::FREE_CALL_INVALID_STATUS,
        PhactMsg::FREE_CALL_NOT_FOUND,
        PhactMsg::GEN_ERR,
        PhactMsg::INVALID_AREA_CODE,
        PhactMsg::INVALID_INTL_NUM_1,
        PhactMsg::INVALID_INTL_NUM_2,
        PhactMsg::INVALID_PAYMENT,
        PhactMsg::INVALID_PHONE,
        PhactMsg::INVALID_PIN,
        PhactMsg::INVALID_PROMO,
        PhactMsg::ITUNES_DOUBLE_TXC,
        PhactMsg::ITUNES_GEN_ERR,
        PhactMsg::ITUNES_INVALID_ACC,
        PhactMsg::ITUNES_INVALID_RCPT,
        PhactMsg::ITUNES_PENDING,
        PhactMsg::ITUNES_SRV_DOWN,
        PhactMsg::PIN_ATTEMPTS_EXCEEDED,
        PhactMsg::RATE_NOT_FOUND,
        PhactMsg::SMS_FROM_LANDLINE,
        PhactMsg::TRY_AGAIN,
        PhactMsg::UNKNOWN_AVT_USER,
        PhactMsg::UNKNOWN_CALL_TYPE,
        PhactMsg::UNKNOWN_COUNTRY,
        PhactMsg::UNKNOWN_USER,
        PhactMsg::PENDING_PAYPAL,
    );

    public function __construct($message, $args = null, $code = 0)
    {
        if ($code === 0) {
            $code = array_search($message, self::$codes);

            if ($code === false) {
                $code = 1;
            }
        }

        if ($args !== null) {
            $message = sprintf($message, $args);
        }

        parent::__construct($message, $code);
    }
}
?>