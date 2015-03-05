<?php

/**
 *  service methods for logged in user
 *
 * @package Service
 * @author Garik G <garik@bigbek.com>
 */
class PhactPrivate
{

    /**
     * @var PhactDB mixed - PhactDB object
     */
    protected $db;

    /**
     * @var UserDB mixed - UserDB object
     */
    protected $userDB;


    /**
     * @var PhilterDB mixed - PhilterDB object
     */
    protected $philtersDB;

    /**
     * @var ReferralDB mixed - ReferralDB object
     */
    protected $referralDB;
    protected $socialUserDB;
    protected $phactsDB;
    protected $friendsDB;
    protected $deviceDB;
    protected $addressBookDB;
    protected $categoryDB;
    /**
     * @var ConfigDB mixed - ConfigDB object
     */
    protected $configDB;


    /**
     * @var IOC mixed - IOC object
     */
    protected $ioc;

    /**
     * @var Config mixed - Config object
     */
    protected $config;

    /**
     * @var array - application data object
     */
    protected $appData;

    /**
     * @var array - User data
     */
    protected $userData;

    /**
     * @var string - customer service email
     */
    protected $csEmail;

    /**
     * @var PhactGeneral mixed - PhactGeneral object
     */
    protected $main;


    /**
     * Constructor
     *
     * @param IOC $ioc - IOC object
     * @param $appData - application data object
     * @param $userData - User data
     * @internal param \PhactDB $PhactDB - PhactDB object
     * @internal param \Config $config - Config object
     */
    public function __construct(IOC $ioc, stdClass $appData, stdClass $userData)
    {
        $this->ioc = $ioc;

        $db = $ioc->resolve('PhactDB');
        $this->config = $ioc->resolve('Config');

        $this->db = $db;

        $this->userDB = new UserDB($db);
        $this->philtersDB = new PhilterDB($db);
        $this->configDB = new ConfigDB($db);
        $this->deviceDB = new DeviceDB($db);
        $this->main = new PhactGeneral($ioc);
        $this->socialUserDB = new SocialUserDB($db);
        $this->phactsDB = new PhactsDB($db);
        $this->friendsDB = new FriendsDB($db);
        $this->categoryDB = new CategoriesDB($db);
        $this->addressBookDB = new AddressBookDB($db);
        $this->appData = $appData;
        $this->userData = $userData;
        $this->csEmail = $this->config->cs->email;
    }


    /**
     *
     *
     * @return array - info array
     */
    public function getServiceInfo()
    {
        $result = array("asdf", "asdf");


        return $result;
    }

    /**
     * Get account information
     * (DID number, balance)
     *
     * @return array
     */
    public function getAccountInfo()
    {
        $result = array();

        $result["user"] = get_object_vars($this->userData);

        return $result;
    }


    /**
     * Set user APNS token
     *
     * @param string $token - APNS token
     * @return int - number of rows affected (0|1)
     */
    public function setAPNSToken($token, $open_udid)
    {
        //@todo should use also UDID
        $this->deviceDB->checkDevice($open_udid, $this->userData->id);
        $device = $this->deviceDB->getByOpenUdid(array(), $open_udid);
        if ($device->user_id != $this->userData->id) {
            throw new Exception("Not permited", 203);
        }
        $device->token = $token;
        $this->deviceDB->update((array)$device, array("id" => $device->id));


        return true;
    }

    public function logout($open_udid)
    {
        $device = $this->deviceDB->getByOpenUdid(array(), $open_udid);
        if ($device->user_id != $this->userData->id) {
            throw new Exception("Not permited", 203);
        }
        $device->token = "";
        $this->deviceDB->update((array)$device, array("id" => $device->id));
        return true;
    }


    public function errorReport($params, $response)
    {
        $request = json_decode($params);
        $report = array(
            "er_number" => $this->userData->usr_id,
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
            "number" => $this->userData->usr_id,
            "description" => $description,
            "comment" => $comment,
            "app_data" => $this->appData->device,
            "app_version" => $this->appData->version);
        $this->db->AppReportError($report);
        return true;
    }


    public function getSocialAccounts()
    {
        $groupMap =
            array(
                "facebook" => array("facebook_like", "facebook", "facebook_invite", "fblike_promo"),
                "google" => array("google"),
                "app" => array("app")
            );


        $users = $this->avtUserDB->getAll(
            array(), array("user_id" => $this->userData->id), "last_updated asc");

        $return = array();
        foreach ($groupMap as $k => $v) {
            foreach ($users as $key => $user) {
                if (in_array($user->signup_source, $v)) {
                    $return[$k] = $user;
                }
            }
        }
        return $return;
    }

    /**
     * @return array
     */
    public function login($open_udid)
    {
        $this->deviceDB->checkDevice($open_udid, $this->userData->id);
        return array("user" => get_object_vars($this->userData));
    }

    /**
     * @return array
     */
    public function philters()
    {

        $philters = $this->philtersDB->getUserPhilters($this->userData->id);
        $active = array();
        $passive = array();
        foreach ($philters as $p) {
            if ($p->status == "active") {
                $active[] = get_object_vars($p);
            } else {
                $passive[] = get_object_vars($p);

            }

        }
        return array("active" => $active, "passive" => $passive);
    }

    /**
     * @param $active
     * @param $passive
     * @return array
     */
    public function syncPhilters($active, $passive)
    {
//        return $active;

        if (is_string($active)) {
            $active = json_decode($active);
        }
        if (is_string($passive)) {
            $passive = json_decode($passive);
        }

        $this->philtersDB->updatePhilters($this->userData->id, $active, $passive);
        return $this->philters();
    }

    /**
     * @param $image
     * @return mixed
     * @throws Exception
     */
    public function doSearch($body, $geo_location = null)
    {
        error_log("search body  ".$body);
        error_log("\n\n\n\-------------\n\n\ngeo ".$geo_location);
        $log = $this->ioc->resolve('Log');
        $body = base64_decode($body);
        $body = str_replace('\"', '"', $body);
        $activePhilters = $this->philtersDB->getUserPhilters($this->userData->id, true);
        $philters = array();
        foreach ($activePhilters as $philter) {
            $philters[] = $philter->philter;
        }
        $searchManager = ImageSearch::getInstance($this->config);
        $result = $searchManager->searchBody($body, $philters, $geo_location, $log);
        error_log("response ready to sent back");
        return $result;
    }


    /**
     * @param $image
     * @return mixed
     * @throws Exception
     */
    public function storeImage($image, $stored = false)
    {
        error_log("Storing image start");
        if ($image == "test") {
            $image = "beer";
            $imagePath = $this->config->media->path->info . "/" . $image . ".jpg";
            $imageUrl = $this->config->media->url . "/images/data/" . $image . ".jpg";
        } else {


//            ini_set('memory_limit', '256M');

            $uid = time();

            $imageD = base64_decode($image);
            $imagePath = $this->config->media->path->info . "/" . $uid . ".jpg";

            $imageUrl = $this->config->media->url . "/images/data/" . $uid . ".jpg";

            $open = fopen($imagePath, "w");
            if (!fwrite($open, $imageD)) {
                throw new Exception("can not upload file please try again", 500);
            }
            fclose($open);
        }
        $log = $this->ioc->resolve('Log');
//        $log->info(__METHOD__ . __LINE__, 100, "\r\n" . var_export($imageUrl, true));
        $googleUrl = sprintf("http://www.google.com/searchbyimage?hl=en&image_url=%s", urlencode($imageUrl));
        error_log("finish");
        /*
        if ($stored) {
            try {
                $searchManager = ImageSearch::getInstance($this->config);
                $location = $searchManager->getImageLocation($imagePath);
            } catch (Exception $e) {
                return array("url" => $googleUrl, "location" => "");
            }
            return array("url" => $googleUrl, "location" => $location["sublocality"]);
        }
        */
        //$googleUrl = sprintf("http://whitetest.naghashyan.com/dyn/admin/do_get_headers?hl=en&image_url='%s'", urlencode($imageUrl));
        return array("url" => $googleUrl);
    }

    /**
     * @param $bestGuess
     * @return array
     */
    public function searchByBestGuess($bestGuess, $location = null)
    {
error_log("search by best guess".$bestGuess." at ".$location);
        $activePhilters = $this->philtersDB->getUserPhilters($this->userData->id, true);
        $philters = array();
        foreach ($activePhilters as $philter) {
            $philters[] = $philter->philter;
        }
        $searchManager = ImageSearch::getInstance($this->config);
        $result = $searchManager->searchByBestGuess($bestGuess, $philters, $location);
        return $result;
    }

    public function resetPassword($newPassword)
    {
        $this->userDB->set(array("usr_pass" => $newPassword), array("id" => $this->userData->id));
        return array("done");
    }

    /**
     * @param $data
     * @return array
     * @throws Exception"id": "1",
     * "user_id": "30",
     * "philter": "asdf",
     * "description": "asdf",
     * "location": "asdf",
     * "date_created": "",
     * "image": "asdf",
     * "printed_image": "adf",
     * "row_inserted": ""
     */

    public function savePhact($philter, $description, $location, $date_created, $image, $printed_image = false, $categories = false)
    {

        $data = array(
            "philter" => $philter,
            "description" => addslashes($description),
            "location" => addslashes($location),
            "date_created" => (int)$date_created,
            "image" => $image,
            "printed_image" => $printed_image,
        );
        if ($image != "test") {
            $mediaDir = $this->config->media->path->info;
            $uid = preg_replace("/\./", "_", preg_replace("/\s/", "_", microtime()));
            $imageD = base64_decode($data["image"]);
            $imagePath = $mediaDir . "/" . $uid . ".jpg";
            $data["image"] = $this->config->media->url . "/images/data/" . $uid . ".jpg";

            $open = fopen($imagePath, "w");
            $wr = fwrite($open, $imageD);
//        if (!$wr) {
//            throw new Exception("can not upload file please try again", 500);
//        }
            fclose($open);

        } else {
            $data["image"] = "test";
        }

        if ($data["printed_image"] && $data["printed_image"] != "test") {
            $uid = preg_replace("/\./", "_", preg_replace("/\s/", "_", microtime()));
            $imageD = base64_decode($data["printed_image"]);
            $imagePath = $mediaDir . "/" . $uid . ".jpg";
            $data["printed_image"] = $this->config->media->url . "/images/data/" . $uid . ".jpg";
            $open = fopen($imagePath, "w");
            $wr = fwrite($open, $imageD);
//            if (!$wr) {
//                throw new Exception("can not upload file please try again", 500);
//            }
        } elseif ($data["printed_image"] && $data["printed_image"] == "test") {
            $data["printed_image"] = "test";
        }
        $data["user_id"] = (int)$this->userData->id;
        fclose($open);
        $id = $this->phactsDB->create($data);
        $result = $this->phactsDB->getById($id);
        if (is_string($categories)) {
            $categories = json_decode($categories);
        }
        if ($categories && count($categories)) {
            foreach ($categories as $category) {
                $this->addPhactToCategory([$id], $category);
            }
        }
        $category = $this->phactsDB->getPhactCategories($id, $this->userData->id);
        error_log(var_export($result, true));
        $result = get_object_vars($result);
        $result["categories"] = $category["categories"];
        $result["color"] = $category["color"];
        return $result;

    }

    /**
     * @param bool $category_id
     * @return array
     */
    public function getUserPhacts($category_id = 0)
    {
        $phacts = $this->phactsDB->getUserPhacts($this->userData->id, $category_id);
        return array("result" => $phacts);
    }

    /**
     * @return array
     */
    public function getOwnPhacts()
    {
        $phacts = $this->phactsDB->getOwnPhacts($this->userData->id);
        return array("result" => $phacts);
    }

    /**
     * @return array
     */
    public function getFriends()
    {
        $data = $this->friendsDB->get([], ["user_id" => $this->userData->id], false);
        $users = [];
        if (!$data) return ["data" => []];
        foreach ($data as $friend) {
            $user = get_object_vars($this->userDB->getById($friend->friend_user_id));
            unset($user["usr_pass"]);
            $users[] = $user;
        }
        return ["data" => $users];
    }

    public function findFriends()
    {
        $socialAccounts = $this->socialUserDB->get([], ["user_id" => $this->userData->id], true);
        $found = [];
//        error_log(var_export($socialAccounts, true));
        if ($socialAccounts and count($socialAccounts)) {


            foreach ($socialAccounts as $socialAccount) {
                //facebook account
                if ($socialAccount->social_account_vendor == "facebook") {

//error_log(var_export($socialAccount->social_account_id, true));
                    if (!$socialAccount->social_access_token) {
                        continue;
                    }

                    $fb = $this->ioc->resolve("Facebook");
                    $fb->setAccessToken($socialAccount->social_access_token);
                    $next = true;
                    $i = 0;

                    while ($next) {
                        try {

                            $result = $fb->getFriends($i, 200);
                        } catch (Exception $e) {

                            break;
                        }

                        $data = $result->data;
                        error_log(__METHOD__ . "::FB result paging ");
                        error_log(var_export($result->paging, true));
                        if (!property_exists($result->paging, "next")) {
                            $next = false;
                        } else {
                            $next = true;
                        }

                        foreach ($data as $user) {
                            $userExists = $this->socialUserDB->get([], ["social_account_id" => $user->id, "social_account_vendor" => "facebook"]);
                            if ($userExists) {
                                if ($userExists->id == $this->userData->id) {
                                    continue;
                                }
                                $friendExists = $this->friendsDB->get([], ["friend_user_id" => $user->id, "user_id" => $this->userData->id]);

                                if (!$friendExists) {
                                    $friend = [
                                        "user_id" => $this->userData->id,
                                        "friend_user_id" => $userExists->user_id,
                                    ];
                                    $this->friendsDB->create($friend, ["ignore"=>true]);
                                    $friend1 = [
                                        "friend_user_id" => $this->userData->id,
                                        "user_id" => $userExists->user_id,
                                    ];
                                    $this->friendsDB->create($friend1, ["ignore"=>true]);
                                    $found[] = $friend;
                                }
                            }
                        }
                        $i = $i + 200;
                    }
                } elseif ($socialAccount->social_account_vendor == "twitter") {
                    /** Perform a GET request and echo the response **/
                    /** Note: Set the GET field BEFORE calling buildOauth(); **/
                    $next = true;
                    $cursor = -1;
                    $ids = [];
                    while ($next) {
                        $url = 'https://api.twitter.com/1.1/friends/ids.json';
                        $getfield = '?user_id=' . $socialAccount->social_account_id . "&cursor=" . $cursor;
                        $requestMethod = 'GET';
                        $twitter = $this->ioc->resolve("Twitter");
                        $response = json_decode($twitter->setGetfield($getfield)
                            ->buildOauth($url, $requestMethod)
                            ->performRequest());
                        if ($response->next_cursor) {
                            $cursor = $response->next_cursor;
                        } else {
                            $next = false;
                        }

                        $ids = array_merge($ids, $response->ids);

                    }

                    if (count($ids)) {
                        foreach ($ids as $id) {
                            $userExists = $this->socialUserDB->get([], ["social_account_id" => $id, "social_account_vendor" => "twitter"]);
                            if ($userExists) {
                                if ($userExists->id == $this->userData->id) {
                                    continue;
                                }
                                $friendExists = $this->friendsDB->get([], ["friend_user_id" => $userExists->user_id, "user_id" => $this->userData->id]);

                                if (!$friendExists) {
                                    $friend = [
                                        "user_id" => $this->userData->id,
                                        "friend_user_id" => $userExists->user_id,
                                    ];
                                    $this->friendsDB->create($friend, ["ignore"=>true]);
                                    $friend1 = [
                                        "friend_user_id" => $this->userData->id,
                                        "user_id" => $userExists->user_id,
                                    ];
                                    $this->friendsDB->create($friend1, ["ignore"=>true]);
                                    $found[] = $friend;
                                }
                            }
                        }
                    }
                }
            }
        }
        $addressBook = $this->addressBookDB->get([], ["user_id" => $this->userData->id, "friend_id" => 0], false);
        if ($addressBook && count($addressBook)) {
            foreach ($addressBook as $item) {
                $emails = explode(",", $item->email);
                if (count($emails)) {
                    foreach ($emails as $email) {
                        $friend = $this->userDB->get([], ["usr_email" => $email]);
                        if ($friend->id == $this->userData->id) {
                            continue;
                        }
                        if ($friend) {
                            $connected = $this->friendsDB->get([], ["friend_user_id" => $friend->id, "user_id" => $this->userData->id]);
                            if (!$connected) {
                                $friendArray = [
                                    "user_id" => $this->userData->id,
                                    "friend_user_id" => $friend->id,
                                ];
                                $this->friendsDB->create($friendArray, ["ignore"=>true]);
                                $friendArray1 = [
                                    "user_id" => $this->userData->id,
                                    "friend_user_id" => $friend->id,
                                ];
                                $this->friendsDB->create($friendArray1, ["ignore"=>true]);
                                $this->addressBookDB->set(["friend_id" => $friend->id], ["id" => $item->id]);
                                $found[] = $friendArray;
                            }
                        }
                    }
                }
            }
        }


        return array("data" => $found);
    }

    public function findSocialFriends()
    {
        $socialAccounts = $this->socialUserDB->get([], ["user_id" => $this->userData->id], true);
        $found = [];
//        error_log(var_export($socialAccounts, true));
        if ($socialAccounts and count($socialAccounts)) {


            foreach ($socialAccounts as $socialAccount) {
                //facebook account
                if ($socialAccount->social_account_vendor == "facebook") {

//error_log(var_export($socialAccount->social_account_id, true));
                    if (!$socialAccount->social_access_token) {
                        continue;
                    }

                    $fb = $this->ioc->resolve("Facebook");
                    $fb->setAccessToken($socialAccount->social_access_token);
                    $next = true;
                    $i = 0;

                    while ($next) {
                        try {

                            $result = $fb->getFriends($i, 200);
                        } catch (Exception $e) {

                            break;
                        }

                        $data = $result->data;
                        error_log(__METHOD__ . "::FB result paging ");
                        error_log(var_export($result->paging, true));
                        if (!property_exists($result->paging, "next")) {
                            $next = false;
                        } else {
                            $next = true;
                        }

                        foreach ($data as $user) {
                            $userExists = $this->socialUserDB->get([], ["social_account_id" => $user->id, "social_account_vendor" => "facebook"]);
                            if (!$userExists) {
//                                var_dump($user);exit;
                                $found[] = [
                                    "social_id"=>$user->id,
                                    "name"=>$user->first_name." ".$user->last_name,
                                    "username"=>$user->first_name,
                                    "avatar"=>$user->picture->data->url,
                                    "vendor"=>"facebook",
                                ];

                            }
                        }
                        $i = $i + 200;
                    }
                } elseif ($socialAccount->social_account_vendor == "twitter") {
                    /** Perform a GET request and echo the response **/
                    /** Note: Set the GET field BEFORE calling buildOauth(); **/
                    $next = true;
                    $cursor = -1;
                    $twFriends = [];
                    while ($next) {
                        $url = 'https://api.twitter.com/1.1/friends/list.json';
                        $getfield = '?user_id=' . $socialAccount->social_account_id . "&cursor=" . $cursor;
                        $requestMethod = 'GET';
                        $twitter = $this->ioc->resolve("Twitter");
                        $response = json_decode($twitter->setGetfield($getfield)
                            ->buildOauth($url, $requestMethod)
                            ->performRequest());
//                        var_dump($response);exit;

                        if ($response->next_cursor) {
                            $cursor = $response->next_cursor;
                        } else {
                            $next = false;
                        }

                        $twFriends = array_merge($twFriends, $response->users);

                    }

                    if (count($twFriends)) {
                        foreach ($twFriends as $user) {
                            $userExists = $this->socialUserDB->get([], ["social_account_id" => $user->id, "social_account_vendor" => "twitter"]);
                            if (!$userExists) {
                                $found[] = [
                                    "social_id"=>$user->id,
                                    "name"=>$user->name,
                                    "username"=>$user->screen_name,
                                    "avatar"=>$user->profile_image_url,
                                    "vendor"=>"twitter",
                                ];
                            }
                        }
                    }
                }
            }
        }
        $addressBook = $this->addressBookDB->get([], ["user_id" => $this->userData->id, "friend_id" => 0], false);
        if ($addressBook && count($addressBook)) {
            foreach ($addressBook as $item) {
                $emails = explode(",", $item->email);
                if (count($emails)) {
                    foreach ($emails as $email) {
                        $friend = $this->userDB->get([], ["usr_email" => $email]);
                        if ($friend->id == $this->userData->id) {
                            continue;
                        }
                        if (!$friend) {
                            $found[] = [
                                "social_id"=>$user->id,
                                "email"=>$email,
                                "name"=>$user->first_name." ".$user->last_name,
                                "vendor"=>"address_book",
                            ];
                        }
                    }
                }
            }
        }


        return array("data" => $found);
    }
    public function getUnreadPhacts()
    {
        $return = $this->phactsDB->getUnreadPhactsCount($this->userData->id);
        return $return;
    }

    /**
     * @param $friends (array)
     * @param $phact
     * @return array
     * @throws Exception
     */
    public function shareWithFriends($friends, $phact)
    {
        if (is_string($friends)) {
            $friends = json_decode($friends);
        }
        if (!$phact) {
            throw new Exception("Something went wrong, please try again", 404);
        }
        error_log("shareWithFriends");
        error_log(var_export($friends, true));
        foreach ($friends as $friend) {
            $user = $this->userDB->getById($friend);
            if (!$user) {
                throw new Exception("No user found", 404);
            }

            //insert new phact for friends
            $sharedPhact = array(
                'user_id' => $user->id,
                'to_id' => $user->id,
                'phact_id' => $phact,
                'from_id' => $this->userData->id,
                'pushed' => 1,
            );
            $this->phactsDB->createSharedPhact($sharedPhact);
            //insert new phact for friends
            $sharedPhact = array(
                'user_id' => $this->userData->id,
                'to_id' => $user->id,
                'phact_id' => $phact,
                'from_id' => $this->userData->id,
                'pushed' => 1,
            );
            $this->phactsDB->createSharedPhact($sharedPhact);

            $badge = $this->phactsDB->getUnreadPhactsCount($user->id);
            $devices = $this->deviceDB->getUserDevices($user->id);
            error_log(var_export($devices, true));
            foreach ($devices as $device) {
                if (!$device->token) continue;
                error_log(var_export($device, true));
                $apns = $this->ioc->resolve('APNS');
                $pnMsg = '' . $this->userData->usr_fname
                    . ' wants to share phact with you';
                $pn = array(
                    'token' => $device->token,
                    'badge' => $badge,
                    'message' => $pnMsg,
                    'custom' => array("id" => $phact)
                );
                $apns->queue($pn);
                $apns->send();

            }


        }
        return true;
    }

    /**
     * @param $phact
     * @return arrays
     */
    public function getPhact($phact)
    {
        $phact = $this->phactsDB->getById($phact);
        $user = $this->userDB->getById($phact->user_id);
        return array("phact" => $phact, "user" => $user);
    }

    /**
     * @param $page
     * @return array
     */
    public function getFeed($page, $category_id = 0)
    {
        return $this->phactsDB->getFeed($this->userData->id, $page, $category_id);

    }

    public function hideFromFeed($feed_id)
    {
        $feed = $this->phactsDB->getFeedItem($feed_id);
        if (!$feed or $feed->user_id != $this->userData->id) {
            throw new Exception("Something went wrong");

        }
        $this->phactsDB->setFeedItem(["hided" => 1], ["id" => $feed_id]);
        return true;
    }

    /**
     * @param $ids
     * @return bool
     */
    public function markAsRead($ids)
    {
        if (is_string($ids)) {
            $ids = json_decode($ids);
        }
        $feed = $this->phactsDB->markAsRead($ids);
        return true;
    }

    /**
     * @param stdClass $data
     * @return mixed
     * @throws Exception
     */
    public function twitterConnect($data)
    {

        if (is_string($data)) {
            $data = json_decode($data);
        }
        $log = $this->ioc->resolve('Log');
        $log->info(__METHOD__, 100, var_export($data, true));

        $existingSocialuser = $this->socialUserDB->get([], ["social_account_id" => $data->id, "social_account_vendor" => "twitter"]);

        //prepare user array from twitter object
        $userArray = get_object_vars($data);
        $userArray["usr_email"] = $data->username . "@twitter";
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
        unset($userArray["firstname"]);
        unset($userArray["lastname"]);
        unset($userArray["open_udid"]);
        if ($existingSocialuser) {
            if ($existingSocialuser->user_id != $this->userData->id) {
                throw new Exception("Twitter account is connected with another user, please change your twitter user");
            }
            $user = $this->userData;
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
        } else {
            //new user
            $socialUser = [
                "first_name" => $data->firstname,
                "last_name" => $data->lastname,
                "picture" => $data->picture,
                "name" => $data->firstname . " " . $data->lastname,
                "username" => $data->username,
                "user_id" => $this->userData->id,
                "social_account_id" => $data->id,
                "social_account_vendor" => "twitter",
            ];
            $this->socialUserDB->create($socialUser);
        }
        $this->deviceDB->checkDevice($open_udid, $this->userData->id);
        $user = $this->userDB->get([], ["id" => $this->userData->id]);
        $result["user"] = get_object_vars($user);
        return $result;


    }

    /**
     * @param $token
     * @param $open_udid
     * @return array
     * @throws Exception
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
            'link' => '',
            'gender' => '',
            'first_name' => '',
            'last_name' => '',
            'email' => '',
            'location' => '',
            'timezone' => '',
            'birthday' => '',
            'picture' => '',
            'social_account_id' => '',
        );


        // get user data from Facebook

        $fields = "&fields=id,first_name,last_name,gender,email,location,birthday,picture.width(200).height(200)";
        $fbUrl = 'https://graph.facebook.com/me?access_token='
            . $token . $fields;


        $response = $http->get($fbUrl, false);

        if ($response !== ''
            && ($fbResData = json_decode($response, true)) !== false
        ) {
//            $log->info(__METHOD__ . " Line:" . __LINE__ . " ::FB data", 100, var_export($fbResData, true));
            $fbData = array_intersect_key($fbResData, $fbData);
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
                $this->userDB->setUserAvatar($this->userData->id, $avatar);
            }
        } else {
            throw new Exception(
                PhactMsg::GEN_ERR,
                $this->csEmail
            );
        }
        if (!$this->userData->usr_fname) {
            $this->userData->usr_fname = $fbData['first_name'];
        }
        if (!$this->userData->usr_lname) {
            $this->userData->usr_lname = $fbData['last_name'];
        }
        if (!$this->userData->usr_dob) {
            if (array_key_exists("dob", $fbData)) {
                $this->userData->usr_dob = $fbData["dob"];
            }
        }
        if (!$this->userData->usr_country) {
            if (array_key_exists("dob", $fbData)) {
                $this->userData->usr_dob = $fbData["usr_country"];
            }
        }

        //TODO get avatar from FB

        //if user exists in social table then it is returning user, return user
        $socUser = $this->socialUserDB->get([], ["social_account_id" => $fbData["id"], "social_account_vendor" => "facebook"]);
//        var_dump($socUser);exit;
        if ($socUser !== false && $socUser->user_id == $this->userData->id) {
            $userArray = get_object_vars($this->userData);
            $this->socialUserDB->set(["social_access_token" => $token], ["id" => $socUser->id]);
            unset($userArray["password"]);
            unset($userArray["realm"]);
            return array("user" => $userArray);
        }
        if ($socUser !== false) {
            throw new Exception("Current facebook user connected with another user.");
        }

        if ($fb = $this->socialUserDB->get([], ["user_id" => $this->userData->id, "social_account_vendor" => "facebook"])) {
            throw new Exception("You have connected to facebook user please use yours account to login");
        }
        if ($socUser !== false) {
            throw new Exception("Current facebook user connected with another user.");
            $fbToSave = $fbData;
            $fbToSave["user_id"] = $this->userData->id;
            unset($fbToSave["id"]);
            $this->socialUserDB->set($fbToSave, array("id" => $socUser->id));
            $userArray = get_object_vars($this->userData);
            if ($avatar) {
                $userArray['usr_avatar'] = $avatar;

            }
            unset($userArray["password"]);
            unset($userArray["realm"]);
            $this->userDB->set($userArray, array("id" => $this->userData->id));
            //checking for new device, is it connected with user, if not connected we need to connect
            $this->deviceDB->checkDevice($open_udid, $this->userData->id);
            return array("user" => $userArray);
        }
        $userData = array();

        $userData['usr_fname'] = $fbData['first_name'];
        $fbData["user_id"] = $this->userData->id;
        //check if device exists to connect with
        $this->deviceDB->checkDevice($open_udid, $this->userData->id);

        $fbData["social_account_id"] = $fbData["id"];
        $fbData["social_account_vendor"] = "facebook";
        unset($fbData["id"]);
        $log->info(__METHOD__ . " Line:" . __LINE__ . " ::Create Soc User", 100, var_export($fbData, true));
        $this->socialUserDB->create($fbData);
        $userArray = get_object_vars($this->userData);
        unset($userArray["password"]);
        unset($userArray["realm"]);
        $result["user"] = $userArray;
        return $result;

    }

    /**
     * @param $name
     * @return array
     */
    public function createCategory($name)
    {
        $category = $this->categoryDB->get(array(), array("name" => $name));

        if (!$category) {
            $categoryID = $this->categoryDB->create(array("name" => $name));
        } else {
            $categoryID = $category->id;
        }
        $userCategory = $this->categoryDB->getById($categoryID, $this->userData->id);

        if ($userCategory) {
            //app need to have id in "category_id" attribute
            $userCategory["category_id"] = $userCategory["id"];
            return $userCategory;
        }

//        var_dump($categoryID);exit;
        $this->categoryDB->connectCategoryUser(array("category_id" => $categoryID, "user_id" => $this->userData->id));
        $category = $this->categoryDB->getById($categoryID, $this->userData->id);
        //app need to have id in "category_id" attribute
        $category["category_id"] = $category["id"];
        return $category;
    }

    /**
     * @param $phact_id
     * @param $category_id
     * @return bool
     * @throws Exception
     */
    public function addPhactToCategory($phact_ids, $category_id)
    {
        if (is_string($phact_ids)) {
            $phact_ids = json_decode($phact_ids);
        }
        foreach ($phact_ids as $phact_id) {
//            $phact = $this->phactsDB->getById($phact_id);

            $category = $this->categoryDB->getById($category_id);
            if (!$category) {
                throw new Exception("Category u selected does not exists");
            }

            try {
                $this->categoryDB->connectCategoryPhact(array("phact_id" => $phact_id, "category_id" => $category_id, "user_id" => $this->userData->id));

            } catch (Exception $e) {
                throw new Exception("Something went wrong");
            }
        }
        return true;
    }

    /**
     * @param $phact_id
     * @param $category_id
     */
    public function removePactFromCategory($phact_id, $category_id)
    {
        $this->categoryDB->disconnectCategoryPhact(array("phact_id" => $phact_id, "category_id" => $category_id, "user_id" => $this->userData->id));
    }

    /**
     * @return array
     */
    public function getCategories()
    {
        return $this->categoryDB->getUserCategories($this->userData->id);
    }

    /**
     * @param $category_id
     * @return bool
     * @throws Exception
     */
    public function deleteCategory($category_id)
    {
        $category = $this->categoryDB->getById($category_id, $this->userData->id);

        if (!$category) {
            throw new Exception("No category to delete");
        }
//        var_dump($category);

        $this->categoryDB->deleteCarefully($category_id, $this->userData->id);
        return true;
    }

    /**
     * @return array
     */
    public function getSettings()
    {
        try {
            $categories = $this->getCategories();
        } catch (Exception $e) {
            $categories = [];
        }
        try {
            $philters = $this->philters();
        } catch (Exception $e) {
            $philters = [];
        }
        return array("categories" => $categories, "philters" => $philters);
    }

    /**
     * @param $phact_id
     * @return bool
     * @throws Exception
     */
    public function deletePhact($phact_id)
    {
        $phact = $this->phactsDB->getById($phact_id);
        if (!$phact) {
            throw new Exception("No phact to delete");
        }
        //if phact is yours
        if ($phact->user_id == $this->userData->id) {
            if ($this->phactsDB->isInFeed($phact_id) && $this->categoryDB->isInCategories($phact_id)) {
//                die("here");
                $phact->status = "deleted";
                $this->phactsDB->set(get_object_vars($phact), ["id" => $phact->id]);
                return true;
            } else {
                $this->phactsDB->delete($phact->id);
            }
        } else {
            $this->categoryDB->disconnectCategoryPhact(["user_id" => $this->userData->id, "phact_id" => $phact->id]);
            $feedItems = $this->phactsDB->getFeedItems(["to_id" => $this->userData->id, "phact_id" => $phact->id]);
            if ($feedItems && count($feedItems)) {
                foreach ($feedItems as $item) {
                    $this->hideFromFeed($item->id);
                }
            }
        }
        return true;
    }

    /**
     * @param $picture
     * @return array
     */
    public function saveAvatar($picture)
    {
        $avatar = Util::saveImage($picture, "base64", "personal", $this->config->media->path->info);
        $this->userDB->set(["usr_avatar" => $avatar], ["id" => $this->userData->id]);
        return ["url" => $avatar];

    }

    /**
     * @param $data
     * @return bool
     */
    public function addressBook($data)
    {
        if (is_string($data)) {
            $data = json_decode($data);
        }
        $this->addressBookDB->delete(["user_id" => $this->userData->id]);
        if (count($data)) {
            foreach ($data as $item) {
                $itemArray = [
                    "user_id" => $this->userData->id,
                    "email" => implode(",", $item->email),
                    "first_name" => implode(",", $item->firstname),
                    "last_name" => implode(",", $item->lastname)
                ];
                $this->addressBookDB->create($itemArray);
            }
        }
        return true;
    }

    public function getProfileNumbers() {
        $friends = $this->friendsDB->get(["count(1) as count"], ["user_id"=>$this->userData->id]);
        if (!$friends) {
            $friends = new stdClass();
            $friends->count = 0;
        }
        $phacts = $this->phactsDB->getOwnPhacts($this->userData->id, true);
        if (!$phacts) {
            $phacts = new stdClass();
            $phacts->count = 0;
        }
        return ["data"=>["friends"=>$friends->count, "phacts"=>$phacts->count]];
    }

    public function inviteFriendsEmail($items) {
        if (is_string($items)) {
            $items = json_encode($items);
        }

        $body = "Join Phact! Make sharing facts about your life fun again. Come see my latest archives!";
        if (count($items)) {
            foreach ($items as $item) {
                foreach ($item->emails as $address) {
                    Util::sendServiceMail([$address], $this->userData->usr_fname." invited you to Phact.me",
                        "Hello Dear ".$item->firstname." ".$item->lastname.",<br>".$body,
                        true
                    );

                }
            }
        }
        return true;
    }

}

?>
