<?php

/**
 *
 * @package Service
 * @author Garik G <garik@bigbek.com>
 */
class Phact
{
    /**
     * @var IOC mixed - IOC object
     */
    protected $ioc;

    /**
     * @var PhactDB mixed - PhactDB object
     */
    protected $db;

    /**
     * @var UserDB mixed - UserDB object
     */
    protected $userDB;

    /**
     * @var UserDB mixed - UserDB object
     */
    protected $socialUserDB;
    protected $phactsDB;
    /**
     * @var ReferralDB mixed - ReferralDB object
     */
    protected $referralDB;
    /**
     * @var ReferralDB mixed - ReferralDB object
     */
    protected $deviceDB;

    /**
     * @var Config mixed - Config object
     */
    protected $config;

    /**
     * @var ConfigDB mixed - ConfigDB object
     */
    protected $configDB;

    /**
     * @var mixed - application data object
     */
    protected $appData;

    /**
     * @var PhactGeneral mixed - PhactGeneral object
     */
    protected $main;

    /**
     * @var string - customer service email
     */
    protected $csEmail;

    /**
     * Constructor
     *
     * @param IOC $ioc - IOC object
     * @param $appData - appData object
     * @internal param \PhactDB $db - PhactDB object
     * @internal param \Config $config - Config object
     */
    public function __construct(IOC $ioc, stdClass $appData)
    {
        $this->ioc = $ioc;
        $db = $ioc->resolve('PhactDB');
        $this->db = $db;
        $this->userDB = new UserDB($db);
        $this->socialUserDB = new SocialUserDB($db);
        $this->deviceDB = new DeviceDB($db);
        $this->phactsDB = new PhactsDB($db);
        $this->philtersDB = new PhilterDB($db);
        $this->configDB = new ConfigDB($db);
            $this->config = $ioc->resolve('Config');
        $this->appData = $appData;
        $this->csEmail = $this->config->cs->email;
        $this->main = new PhactGeneral($ioc);
    }

    /**
     * @return array - info array
     */
    public function getServiceInfo()
    {

        $result = array();


        return $result;
    }


    /**
     * Check if user exists by specified openUDid
     * Request Aarki
     * Register/update device
     *
     * @param stdClass $data - device data
     * @throws PhactException
     * @return int - install has been done or not (1|0)
     */
    public function freshInstall(stdClass $data)
    {
        // get user by open udid

        if (!isset($data->open_udid)) {
            throw new PhactException(PhactMsg::EMPTY_OPEN_UDID);
        }

        $map = DeviceDB::$convMap;
        $data = (array)$data;

        ksort($map);
        ksort($data);

        $keys = array_values(array_intersect_key($map, $data));
        $values = array_values(array_intersect_key($data, $map));
        $deviceData = array_combine($keys, $values);

        $exists = $this->deviceDB->getByOpenUdid(array(), $data["open_udid"]);
        if ($exists) {
            $result = $this->deviceDB->update($data, array("id"=>$exists->id));
        } else {
            $result = $this->deviceDB->create($data);
        }

        // register/update device


        // if > 1 then 1, else 0

        return (int)($result || 0);
    }

    /**
     * test push notification
     *
     * @param $destPhoneNumber
     * @return bool
     * @throws PhactException
     */
    public function testPushNotification($open_udid, $badges)
    {
        $invitee = $this->deviceDB->getByOpenUdid(array(), $open_udid);
        if (!$invitee->token) {
            throw new Exception("no device to send");
        } else {
            try {
                $apns = $this->ioc->resolve('APNS');
                $pn = array(
                    'token' => $invitee->token,
                    'badge' => $badges,
                    'message' => "test push notification",
                );
                $apns->queue($pn);
                $apns->send();
            } catch (Exception $e) {
                throw new PhactException(PhactMsg::TRY_AGAIN);
            }
        }
        return true;
    }


    public function errorReport($params, $response)
    {
        $request = json_decode($params);
        $report = array(
            "er_number" => '',
            "er_request" => $request->method,
            "er_parameters" => $params,
            "er_description" => $response,
            "app_version" => $this->appData->version);
        $this->db->ReportError($report);
        return true;
    }


    public function  appErrorReport($description = null, $comment = null, $openUdid = null)
    {
        $report = array(
            "number" => $openUdid,
            "description" => $description,
            "comment" => $comment,
            "app_data" => $this->appData->device,
            "app_version" => $this->appData->version);
        $this->db->AppReportError($report);
        return true;
    }

    /**
     * @param stdClass $data
     * @return mixed
     * @throws Exception
     */
    public function twitterConnect($data) {

        if (is_string($data)) {
            $data = json_decode($data);
        }

        $log = $this->ioc->resolve('Log');
        $log->info(__METHOD__, 100, var_export($data, true));
        $existingSocialuser = $this->socialUserDB->get([], ["social_account_id"=>$data->id, "social_account_vendor"=>"twitter"]);

        //prepare user array from twitter object
        $userArray = get_object_vars($data);
        $userArray["usr_email"] = $data->username."@twitter";
        $userArray["usr_fname"] = $data->firstname;
        $userArray["usr_lname"] = $data->lastname;
        $userArray["usr_pass"] = $data->id;
        $avatar = null;
        if ($data->picture) {
            $avatar = Util::saveImage($data->picture, "url", "personal", $this->config->media->path->info);
            $userArray["usr_avatar"] = $avatar;
        }

        $open_udid = $userArray["open_udid"];
        unset($userArray["id"]);
        unset($userArray["username"]);
        unset($userArray["picture"]);
        unset($userArray["firstname"]);
        unset($userArray["lastname"]);
        unset($userArray["open_udid"]);
        if ($existingSocialuser) {
            $user = $this->userDB->get([], ["id"=>$existingSocialuser->user_id]);
//            var_dump($existingSocialuser);exit;
            if (!$user) {

                $id = $this->userDB->create($userArray);
            } else {


                $id = $user->id;
                $userToSave = [];
                if (!$user->usr_fname) {
                    $userToSave["usr_fname"] = $data->firstname;
                }
                if (!$user->usr_lname) {
                    $userToSave["usr_lname"] = $data->lastname;
                }
                if (!$user->usr_email) {
                    $userToSave["usr_email"] = $data->username . "@twitter";
                }
                if (!$user->usr_pass) {
                    $userToSave["usr_pass"] = $data->id;
                }
                if ($avatar && !$user->usr_avatar) {
                    $userToSave["usr_avatar"] = $avatar;
                }

                if (count($userToSave))
                    $this->userDB->set($userToSave, ["id" => $id]);
            }
        } else {
            //new user
            $id = $this->userDB->create($userArray);
            var_dump($id);
            $socialUser = [
                "first_name"=>$data->firstname,
                "last_name"=>$data->lastname,
                "picture"=>$data->picture,
                "name"=>$data->firstname." ".$data->lastname,
                "username"=>$data->username,
                "user_id"=>$id,
                "social_account_id"=>$data->id,
                "social_account_vendor"=>"twitter",
            ];
            $this->socialUserDB->create($socialUser);
        }
        $this->deviceDB->checkDevice($open_udid, $id);
        $user = $this->userDB->get([], ["id"=>$id]);
        $result["user"] = get_object_vars($user);
        return $result;



    }

    public function test()
    {


        return true;
    }

    /**
     * Create/update Phact user data from facebook
     * Update (optionally) regular user first name,
     * last name and email
     *
     * @param stdClass $data - user data from application
     * @throws PhactException
     * @return array - array og Phact and regular user
     * create/update results:
     * Phact_user - 0 (no operation performed)
     *          - 1 (Phact user has been updated)
     *          - 2 (Phact user has been created)
     * user - 0 (no operation performed)
     *      - 1 (regular user has been updated)
     */
    public function fbConnect($token, $open_udid)
    {
        $log = $this->ioc->resolve('Log');
        $log->info(__METHOD__, 100, "fbConnect");
        $log->info(__METHOD__, 100, var_export($token, true));
        $result = array(
            'social_user' => 0,
            'user' => 0
        );

        $http = new HTTP();

        $fbData = array(
            'id' => '',
            'name' => '',
            'username' => '',
            'picture' => '',
            'link' => '',
            'gender' => '',
            'first_name' => '',
            'last_name' => '',
            'email' => '',
            'location' => '',
            'timezone' => '',
            'birthday' => '',
            'social_account_id' => '',
        );


        // get user data from Facebook
        $fields = "&fields=id,first_name,last_name,gender,email,location,birthday,picture.width(200).height(200)";
        $fbUrl = 'https://graph.facebook.com/me?access_token='
            . $token.$fields;


        $response = $http->get($fbUrl, false);
        if ($response !== ''
            && ($fbResData = json_decode($response, true)) !== false
        ) {
//            $log->info(__METHOD__ . " Line:" . __LINE__ . " ::FB data", 100, var_export($fbResData, true));
            $fbData = array_intersect_key($fbResData, $fbData);
//            var_dump($fbData);exit;
            $fbData['location'] = (isset($fbData['location']['name']))
                ? $fbData['location']['name']
                : '';

            if ($fbData['birthday'] !== '') {
                $fbData['dob'] = date('Y-m-d', strtotime($fbData['birthday']));
            }
            $fbData["social_access_token"] = $token;

            $avatar = false;
            if (!$fbData["picture"]["data"]["is_silhouette"]) {
                $fbData["picture"] = $fbData["picture"]["data"]["url"];
                $avatar = Util::saveImage($fbData["picture"], "url", "personal", $this->config->media->path->info);
            }

        } else {
            throw new PhactException(
                PhactMsg::GEN_ERR,
                $this->csEmail
            );
        }
        //if user exists in social table then it is returning user, return user
        $socUser = $this->socialUserDB->get([], ["social_account_id" => $fbData["id"]]);
        if ($socUser !== false) {
            $fbToSave = $fbData;
            unset($fbToSave["id"]);
//            $log->info(__METHOD__ . " Line:" . __LINE__ . " ::FB data", 150, var_export($fbToSave, true));
            $this->socialUserDB->set($fbToSave, ["id" => $socUser->id]);
            $user = $this->userDB->get([], ["id" => $socUser->user_id]);
            if ($user) {
                //checking for new device, is it connected with user, if not connected we need to connect
                $log->info(__METHOD__ . " Line:" . __LINE__ . " ::FB data", 150, var_export($user->id, true));
                $this->deviceDB->checkDevice($open_udid, $user->id);
                return array("user" => get_object_vars($user));
            }

            //no user referenced , checking if there is user with email
            $user = $this->userDB->get([], ["usr_email" => $fbData["email"]]);
            if ($user) {
                $this->socialUserDB->set(["user_id" => $user->id], ["id" => $socUser->id]);
                return array("user" => get_object_vars($user));
            }
        }
        $userData = [];
        $userData['usr_fname'] = $fbData['first_name'];
        $userData['usr_lname'] = $fbData['last_name'];
        $userData['usr_pass'] = $fbData['id'];
        $userData['usr_email'] = $fbData['email'];
        if ($avatar) {
            $userData['usr_avatar'] = $avatar;

        }
//            if (array_key_exists("dob", $fbData)) {
//                $userData["usr_dob"] = $fbData["dob"];
//            }
        if (array_key_exists("location", $fbData)) {
            $userData["usr_country"] = $fbData["location"];
        }
        $log->info(__METHOD__ . " LINE : " . __LINE__ . "::Create User with array", 100, var_export($userData, true));

        $userId = $this->userDB->create($userData);
        $log->info(__METHOD__ . ":: User created", 100, var_export($userId, true));
        $fbData["user_id"] = $userId;
        //check if device exists to connect with
        $this->deviceDB->checkDevice($open_udid, $userId);

        $fbData["social_account_id"] = $fbData["id"];
        $fbData["social_account_vendor"] = "facebook";
        unset($fbData["id"]);
        error_log(var_export($fbData, true));

        $this->socialUserDB->create($fbData);
        $result["user"] = $this->userDB->get(array(), array("id" => $userId));
        return $result;


        // Update user first name, last name, email
        // and birthday


        if (!empty($userData)) {
            $result['user'] = $this->userDB->set(
                $userData,
                array('id' => $this->userData->id)
            );
        }
        $log->info(__METHOD__, 100, json_encode($result));

        return $result;
    }

    /**
     * SignUp method params :
     * data
     * {
     * usr_fname
     * usr_lname
     * #usr_pass
     * #usr_open_udid
     * #usr_email
     * usr_dob
     * usr_country
     *
     * app_version
     * app_name
     * device_name
     * apns_token
     * }
     * @param stdClass $data
     * @return mixed
     */
    public function signUp(stdClass $data)
//    public function signUp($data)
    {
        $log = $this->ioc->resolve('Log');
        $log->info(__METHOD__, 100, var_export($data, true));
        if (is_string($data)) {
            $data = json_decode($data);
        }
//    public function signUp($data) {
        //only for local tests
//        var_dump($data);exit;
        $userArray = get_object_vars($data);
        $log->info(__METHOD__ . "-UserArray", 100, var_export($userArray, true));
        $mandatoryFields = array("usr_email" => "Email", "usr_pass" => "Password");
        foreach (array_keys($mandatoryFields) as $f) {
            $log->info(__METHOD__ . "Mandatory FIelds", 100, var_export($userArray, true));
            $log->info(__METHOD__ . "Mandatory FIelds checking", 100, var_export($f, true));
            if (!array_key_exists($f, $userArray)) {
                throw new Exception($mandatoryFields[$f] . " is required for SignUp");
            }
        }

        $existingUser = $this->userDB->get(array(), array("usr_email" => $data->usr_email));
        if ($existingUser) {
            $log->info(__METHOD__ . "Returning user", 100, var_export($existingUser, true));
            throw new Exception("user with " . $data->usr_email . " already exists try login in ");
//            return array("error" => );
        }
        $open_udid = $userArray["open_udid"];
        unset($userArray["open_udid"]);
        $id = $this->userDB->create($userArray);
        $this->deviceDB->checkDevice($open_udid, $id);
        $user = $this->userDB->get(array(), array("id" => $id));
        $log->info(__METHOD__ . "user created", 100, var_export($user, true));
//        die(var_dump($user));
        $result["user"] = get_object_vars($user);
        return $result;
    }

    public function forgotPassRequest($email)
    {
        $user = $this->userDB->get(array(), array("usr_email" => $email));
        if (!$user) {
//            die("here");
            throw new Exception("user not found");
        }
        $pin = rand(1000, 9999);
        $user->reset_pass_hash = $pin;
        $this->userDB->set(array("reset_pass_hash" => $pin), array("id" => $user->id));
        Util::sendServiceMail(array($user->usr_email), "Phact password reset request", "your pin is - " . $pin);
        return array("pin code sent");
    }

    public function resetPassword($pin, $newPassword)
    {
        $user = $this->userDB->get(array(), array("reset_pass_hash" => $pin));
        if (!$user) {
            throw new Exception("pin is incorect");
        }
        $this->userDB->set(array("usr_pass" => $newPassword), array("id" => $user->id));
        return array("done");
    }


    public function getApiContext()
    {
        return new PayPal\Rest\ApiContext(new PayPal\Auth\OAuthTokenCredential('AWYmQRA1C8AP90nmfqSe23oxyB4TLz6mAysYhF_wdX18rmfgfd4xOLCbteiF', 'EPASZhDtEjreEfUyyWV13jwHs9nhiRzLnC6Gs_2p9a8Mgq4ftTWV8-zXmbJl'));

    }

    public function getDefaultPhilters()
    {
        $philters = $this->philtersDB->get(array(), array("is_default" => 1), false);
        return array("philters" => $philters);
    }
}

?>