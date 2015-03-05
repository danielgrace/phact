<?php
abstract class DB
{
    /**
     * @var PhactDB - DB (PDO) object
     */
    protected $db;
    
    /**
     * @param PhactDB $db - DB (PDO) object
     */    
    public function __construct($db)
    {
        $this->db = $db;
    }
}
?>