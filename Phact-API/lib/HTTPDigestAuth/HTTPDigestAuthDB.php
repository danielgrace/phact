<?php
class HTTPDigestAuthDB
{
    private $db;

    public function __construct(PhactDB $db)
    {
        $this->db = $db;
    }

    public function create($nonce)
    {
        $query = 'INSERT IGNORE INTO nonces (nonce) VALUES (:nonce)';
        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':nonce', $nonce, PDO::PARAM_STR, 32);
        $stmt->execute();
    }

    public function update($oldNonce, $newNonce)
    {
        $query = 'UPDATE nonces SET nonce=:new_nonce, nc=0, date_created=NOW() WHERE nonce=:old_nonce';
        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':new_nonce', $newNonce, PDO::PARAM_STR, 32);
        $stmt->bindParam(':old_nonce', $oldNonce, PDO::PARAM_STR, 32);

        $stmt->execute();
    }

    public function read($nonce)
    {
        $query = 'SELECT nc, NOW() - date_created as datediff FROM nonces WHERE nonce=:nonce';

        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':nonce', $nonce, PDO::PARAM_STR, 32);

        $stmt->execute();
        $result = $stmt->fetch();

        return $result;
    }

    public function increaseUsage($nonce)
    {
        $query = 'UPDATE nonces SET nc=nc+1 WHERE nonce=:nonce';
        $stmt = $this->db->prepare($query);

        $stmt->bindParam(':nonce', $nonce, PDO::PARAM_STR, 32);
        $stmt->execute();
    }

}
?>