<?php

/**
 * PDO wrapper, performs connection to AVT database
 *
 * @author Garik G <garik@bigbek.com>
 */
class PhactDB extends PDO
{

    /**
     * @var object - PDO object
     */
    private $dbh;

    /**
     * @var object - Config object
     */
    private $config;

    /**
     * single row fetch mode
     */
    const FETCH_SINGLE = 0;

    /**
     * all rows fetch mode
     */
    const FETCH_ALL = 1;

    /**
     * Constructor
     *
     * @param Config $config - Config object
     */
    public function __construct(Config $config)
    {
        $options = array(
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
            PDO::ATTR_ORACLE_NULLS => PDO::NULL_TO_STRING
        );

        $avt = $config->avt->db;

        $dsn = 'mysql:dbname=' . $avt->name . ';host=' . $avt->host;
        $user = $avt->user;
        $pwd = $avt->pwd;

        $this->config = $config;
        $this->dbh = parent::__construct($dsn, $user, $pwd, $options);
    }

    public function create($table, $map, $data, $options = array())
    {
        $dataStmt = array();

        $fields = array_keys($data);
        $values = array_values($data);

        foreach ($fields as $field) {
            $dataStmt[] = $field . '=?';
        }

        $ignore = (isset($options['ignore']) &&
            $options['ignore'] === true)
            ? 'IGNORE'
            : '';

        $query = 'INSERT ' . $ignore . ' INTO ' . $table . ' SET ';
        $query .= implode(',', $dataStmt);

        if (isset($options['duplicate'])
            && is_array($options['duplicate'])
        ) {
            $duplicate = $options['duplicate'];

            $query .= ' ON DUPLICATE KEY UPDATE ';

            $dplStmt = array();
            $dplKeys = array_keys($duplicate);
            $dplValues = array_values($duplicate);

            foreach ($dplKeys as $field) {
                $dplStmt[] = $field . '=?';
            }

            $query .= implode(',', $dplStmt);

            $fields = array_merge($fields, $dplKeys);
            $values = array_merge($values, $dplValues);
        }
        $stmt = $this->prepare($query);

        foreach ($values as $k => $value) {
            $field = $fields[$k];

            $stmt->bindValue(
                $k + 1,
                $value,
                $map[$field][0]
            );
        }

        $stmt->execute();

        return $stmt;
    }

    public function read(
        $table,
        $map,
        $what,
        $where = array(),
        $fetchMode = self::FETCH_SINGLE,
        $sort = false
    )
    {
        $query = 'SELECT ';
        $whereStmt = array();
        $whereFields = array_keys($where);
        $values = array_values($where);

        $query .= (empty($what))
            ? '*'
            : implode(',', $what);

        $query .= ' FROM ' . $table;

        if (!empty($where)) {
            foreach ($whereFields as $field) {
                $whereStmt[] = $field . '=?';
            }

            $query .= ' WHERE ' . implode(' AND ', $whereStmt);
        }
//echo $query;
        $stmt = $this->prepare($query);

        foreach ($values as $k => $value) {
            $field = $whereFields[$k];

            $stmt->bindValue(
                $k + 1,
                $value,
                $map[$field][0]
            );
        }

        if ($sort) {
            $stmt->queryString .= ' order by '.$sort;

        }

//        die(var_dump($stmt));

        $stmt->execute();

        switch ($fetchMode) {
            case self::FETCH_ALL:
                $data = $stmt->fetchAll();
                break;
            case self::FETCH_SINGLE:
            default:
                $data = $stmt->fetch();
                break;
        }

        return $data;
    }

    public function update($table, $map, $what, $where, $order = null, $limit = null)
    {
        $whatStmt = array();
        $whereStmt = array();
        $whatFields = array_keys($what);
        $whereFields = array_keys($where);

        $fields = array_merge(
            $whatFields,
            $whereFields
        );

        $values = array_merge(
            array_values($what),
            array_values($where)
        );

        foreach ($whatFields as $field) {
            $whatStmt[] = $field . '=?';
        }

        foreach ($whereFields as $field) {
            $whereStmt[] = $field . '=?';
        }

        $query = 'UPDATE ' . $table . ' SET ';
        $query .= implode(', ', $whatStmt);
        $query .= ' WHERE ' . implode(' AND ', $whereStmt);

        if ($order !== null) {
            $query .= ' ORDER BY ' . $order;
        }
        if ($limit !== null) {
            $query .= ' LIMIT ' . $limit;
        }
        $stmt = $this->prepare($query);

        foreach ($values as $k => $value) {
            $field = $fields[$k];

            $stmt->bindValue(
                $k + 1,
                $value,
                $map[$field][0]
            );
        }
        $stmt->execute();

        return $stmt->rowCount();
    }

    public function delete($table, $map, $where, $order = null, $limit = null)
    {
        $whereStmt = array();
        $whereFields = array_keys($where);

        $fields =
            $whereFields
        ;

        $values =
            array_values($where)
        ;



        foreach ($whereFields as $field) {
            $whereStmt[] = $field . '=?';
        }

        $query = 'DELETE FROM ' . $table . ' ';
        $query .= ' WHERE ' . implode(' AND ', $whereStmt);

        if ($order !== null) {
            $query .= ' ORDER BY ' . $order;
        }
        if ($limit !== null) {
            $query .= ' LIMIT ' . $limit;
        }
        $stmt = $this->prepare($query);

        foreach ($values as $k => $value) {
            $field = $fields[$k];

            $stmt->bindValue(
                $k + 1,
                $value,
                $map[$field][0]
            );
        }
        $stmt->execute();

        return $stmt->rowCount();
    }



    public function ReportError($error)
    {
        $query = sprintf("insert into error_reports (`er_number`, `er_request`, `er_parameters`, `er_description`, `app_version` )
        VALUES ('%s', '%s', '%s', '%s', '%s')",
            $error["er_number"],
            $error["er_request"],
            $error["er_parameters"],
            $error["er_description"],
            $error["app_version"]
        );
        $stmt = $this->prepare($query);
        $stmt->execute();
        return true;
    }

    public function AppReportError($error)
    {
        $query = sprintf("insert into app_error_reports (`user_id`, `description`, `comment`, `app_data`, `app_version` )
        VALUES ('%s', '%s', '%s', '%s', '%s')",
            $error["number"],
            addslashes($error["description"]),
            addslashes($error["comment"]),
            $error["app_data"],
            $error["app_version"]
        );
        $stmt = $this->prepare($query);
        $stmt->execute();
        return true;
    }

    public function logRequest($log)
    {
        $query = sprintf("insert into request_log (`user_id`, `request`,`request_header`, `method`, `response`, `response_time`, `app_version`, `api_version`, `app_data` )
        VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')",
            $log["user"],
            addslashes($log["request"]),
            addslashes($log["request_header"]),
            $log["method"],
            addslashes($log["response"]),
            $log["response_time"],
            $log["app_version"],
            $log["api_version"],
            $log["app_data"]
        );
//        die($query);
        $stmt = $this->prepare($query);
        $stmt->execute();
        return true;
    }

    /**
     * Destructor
     */
    public function __destruct()
    {
        $this->dbh = null;
    }



}

?>