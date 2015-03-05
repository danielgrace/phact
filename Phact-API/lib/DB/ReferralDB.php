<?php
class ReferralDB extends DB
{
    const TABLE = 'user_referrals';

    private $map = array(
        'id'                    => array(PDO::PARAM_INT, 11),
        'user_id'               => array(PDO::PARAM_INT),
        'referral_code'         => array(PDO::PARAM_STR, 100),
        'own_code'              => array(PDO::PARAM_STR, 100),
        'referral_status'       => array(PDO::PARAM_STR),
        'referral_bonus_price'  => array(PDO::PARAM_INT)
    );

    public function create($phoneNumber, $refCode, $ownCode, $price)
    {
        $data = array(
            'user_id'               => $phoneNumber,
            'referral_code'         => $refCode,
            'own_code'              => $ownCode,
            'referral_bonus_price'  => $price
        );

        $this->db->create(
            self::TABLE,
            $this->map,
            $data,
            array('ignore' => true)
        );

        return $this->db->lastInsertId();
    }

    public function getOwnCode($phoneNumber)
    {
        return $this->db->read(
            self::TABLE,
            $this->map,
            array('own_code'),
            array('user_id' => $phoneNumber)
        );
    }

    public function setStatus($phoneNumber, $status)
    {
        $query = 'UPDATE user_referrals
                  SET referral_status=:status
                  WHERE user_id=:phoneNumber
                  AND referral_status=\'pending\'
                  AND referral_code IS NOT NULL';

        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':status', $status, PDO::PARAM_STR);
        $stmt->bindParam(':phoneNumber', $phoneNumber, PDO::PARAM_STR);

        $stmt->execute();

        return $stmt->rowCount();
    }
}

?>