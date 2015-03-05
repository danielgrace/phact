<?php

require_once dirname(__FILE__) . "/../Filters/ResultsFilter.php";

class ImageSearch {

    /**
     * @var passed arguemnts
     */
    private $config;

    /**
     * @var singleton instance of class
     */
    private static $instance = null;
	
	private $RESULTS_LENGTH = 256;

    private $google = 'http://www.google.com';

    private $user_agent = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.62 Safari/537.36';

    /**
     * Initializes DB mappers
     *
     * @param object $config
     * @param object $args
     * @return
     */

    function __construct($config) {
        $this -> config = $config;

    }

    /**
     * Returns an singleton instance of this class
     *
     * @param object $config
     * @param object $args
     * @return
     */
    public static function getInstance($config) {

        if (self::$instance == null) {
            self::$instance = new ImageSearch($config);
        }
        return self::$instance;
    }

    public function searchBody($webPageHTML, $philters, $clientGeoLocation, $log) {
        $bestGuess = $this->getBestGuess($webPageHTML);
        error_log("Got best guess");
        error_log(var_export($bestGuess, true));
        // $log->info(__METHOD__.__LINE__, 100, "\r\n" . var_export($bestGuess, true));
        $info = array();
        if($bestGuess) {
            $info = $this -> searchByBestGuess($bestGuess, $philters, $clientGeoLocation, $log);
        }
        else { // when no best guess available
            throw new Exception("No result found");
            $result = array(
                array("filter"=>"pop", "description"=>"In this mobile era, winning brands must be experience enablers and Magento Mobile will create a cohesive and fulfilling brand experience for consumers who connect via their mobile phone - anytime, anywhere."),
                array("filter"=>"places", "description"=>"In this mobile era, winning brands must be experience enablers and Magento Mobile will create a cohesive and fulfilling brand experience for consumers who connect via their mobile phone - anytime, anywhere."),
                array("filter"=>"past", "description"=>"In this mobile era, winning brands must be experience enablers and Magento Mobile will create a cohesive and fulfilling brand experience for consumers who connect via their mobile phone - anytime, anywhere."),
            );
//           throw new Exception("sorry no result found, keep trying", 404);
        }
        if (isset($result)) {
            return array("result"=>$result);
        }
        return $info;
    }
    
    public function searchByBestGuess($bestGuess, $philters, $clientGeoLocation) {
        error_log("searching for Geolocation");
        $geoLocation = $this->getGeoLocation($bestGuess);
        error_log("Geolocation is:");
        error_log(var_export($geoLocation, true));
        $key = array_search("place", $philters);
        if(!is_null($key)) {
            if(!is_null($geoLocation)) {
                $philters[$key] = "";
                foreach ($geoLocation as $location) {
                    $philters[$key] .= $location.", ";
                }
                $philters[$key] = substr($philters[$key], 0, -2);
            }
        }
        
        $philters[] = "clientGeoLocation";
        
//        error_log("geoLocation". "::" . var_export($geoLocation, true));
        $info = $this->getCategoryResult($bestGuess, $philters, $clientGeoLocation);
        error_log("info parsed by categories");
        $info = $this->getFinalResults($info);
        error_log("filters applied");
//      $geoLocationStr = implode(", ", $geoLocation);
        return array("result"=>$info);
    }

    private function getCategoryResult($bestGuess, $categoriesArray, $clientGeoLocation) {
        $webPagesJson = $this->categorySearch($bestGuess, $categoriesArray, $clientGeoLocation);
        $resultCount = 10;
		
        foreach ($categoriesArray as $key => $category) {
            if($category == "past") {
                $categories[0] = "past";
            } 
            else if($category == "pop") {
                $categories[2] = "pop";
            }
			else if($category == "clientGeoLocation") {
                $categories[3] = "place";
            }
            else if($category != "past" && $category != "pop") {
                $categories[1] = $category;
                $info['places'] = $category;
            }
        }
        ksort($categories);
        foreach ($webPagesJson as $key => $jsonResult) {
            if($categoriesArray[$key] != "pop" && $categoriesArray[$key] != "past") {
                $categoriesArray[$key] = "place";
            }
            
            $info['results'][] = $this->getResult($jsonResult, $bestGuess, $resultCount, $categoriesArray[$key]);
        }
		
		
        return $info;
    }

    private function fetchGoogle($terms = "sample image")
    {
        error_log(__METHOD__.__LINE__. "\r\n" . var_export($terms, true));
        $url = $this->google."/searchbyimage?hl=en&image_url=".urlencode($terms);
        $searched = $this->sendCurl($searched, $url);

        return $searched;
    }

    private function getBestGuess($webpage) {
        $matches = array();
        preg_match('/Best guess for this image:[^<]+<a[^>]+>([^<]+)/', $webpage, $matches);
        return (count($matches) > 1 ? $matches[1] : false);
    }

    private function getVisuallySimilarImages($webpage) {
        $matches = array();
        preg_match('/Visually similar images/', $webpage, $matches);
        return (count($matches) > 0 ? $matches[0] : false);
    }

    private function getResult($jsonResult, $bestGuess = false, $resultCount = false, $category = false) {
        $webPageObject = json_decode($jsonResult);
        $result = array();
        if($bestGuess){
            foreach ($webPageObject->items as $key => $item) {
                $result[$key]['filter'] = $category;
                $result[$key]['title'] = $item->title;
                $result[$key]['description'] = $item->snippet;
            }
        }
        else {
            throw new Exception("No result this time please make another shot", 404);
        }
		$resultsFilter = ResultsFilter::getInstance();
		$result = $resultsFilter->filterResult($result);
		
        return $result;
    }

    private function categorySearch($searchBy, $categories, $clientGeoLocation) {
        $searchBy = urlencode($searchBy);
        $searched = array();
        $urls = array();
        $urls[]=$this->google."/cse?q=$searchBy&hl=en";
		 
        if($categories) {
            $urls = array();
            foreach ($categories as $key => $category) {
                $categorySearch = "";
                $searchKey = $searchBy;
				if($category == "past") {
                     $categorySearch = "q=history+OR+origins+tradition+";
                   // $categorySearch = "q=history+";
                }
                else if($category == "pop") {
                    $categorySearch = "as_qdr=m3&as_q=popular&q=trends+";
                }
                else if($category == "clientGeoLocation") {
                    $searchKey = "q=" . urlencode($clientGeoLocation);
                }
                else {
                    $searchKey = "q=" . urlencode($category);
                }
       //        $urls[$key] = "https://www.googleapis.com/customsearch/v1?key=AIzaSyC-IS6bMn-D_vYsGwLij9HB5IVFACPU7GY&cx=002228449611518064734:-ctaybp6c3g&".$categorySearch.$searchKey;
                 $urls[$key] = "https://www.googleapis.com/customsearch/v1?key=AIzaSyA_JUUmchY3mTLYoEpZTY51SxHeU_fQyJk&cx=002228449611518064734:-ctaybp6c3g&".$categorySearch.$searchKey;
                // $urls[$key] = "http://whitetest.naghashyan.com/dyn/admin/do_get_headers?".$categorySearch.$searchKey;
            }
        }

        foreach ($urls as $key => $url) {
            $searched[$key] = $this->sendCurl($searched[$key], $url);
        }
        error_log("API search results");
        error_log(var_export($searched, true));
        return $searched;
    }


    public function sendCurl($searched, $url) {
        $searched = "";
        $curl = curl_init();
        curl_setopt ($curl, CURLOPT_URL, $url);
        curl_setopt ($curl, CURLOPT_USERAGENT, $this->user_agent);
        curl_setopt ($curl, CURLOPT_HEADER, 0);
        curl_setopt ($curl, CURLOPT_FOLLOWLOCATION, 1);
        curl_setopt ($curl, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt ($curl, CURLOPT_REFERER, $this->google);
        curl_setopt ($curl, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt ($curl, CURLOPT_CONNECTTIMEOUT,120);
        curl_setopt ($curl, CURLOPT_TIMEOUT,120);
        curl_setopt ($curl, CURLOPT_MAXREDIRS,2);
        $searched = $searched.curl_exec($curl);
        curl_close ($curl);

        return $searched;
    }

    private function getGeoLocation($bestGuess) {
        $url = sprintf("http://maps.googleapis.com/maps/api/geocode/json?address=%s&sensor=true&language=en", urlencode($bestGuess));
        $gmapJson = file_get_contents($url);
        $address_data_object = json_decode($gmapJson);
        if (!is_object($address_data_object)) {
            return null;
        }
        $valid_result = null;
        if (isset($address_data_object->results)) {
            $valid_result = $address_data_object->results;
        }
        if (empty($valid_result)) {
            $bestGuessWords = explode(" ", $bestGuess);
            $comb = array();
            $resultFound = false;
            for($i = count($bestGuessWords) - 1; $i > 0; $i--) {
                $comb[$i] = $this->getCombinations($bestGuessWords,$i);
                foreach ($comb[$i] as $words) {
                    $newGuess = "";
                    foreach($words as $word) {
                        $newGuess .= $word . " ";
                    }
                    $newGuess = substr($newGuess, 0, -1);
                    $url = sprintf("http://maps.googleapis.com/maps/api/geocode/json?address=%s&sensor=true&language=en", urlencode($newGuess));
                    $gmapJson = file_get_contents($url);
                    $address_data_object = json_decode($gmapJson);
                    if (!is_object($address_data_object)) {
                        return null;
                    }
                    $valid_result = null;
                    if (isset($address_data_object->results)) {
                        $valid_result = $address_data_object->results;
                    }
                    if(!empty($valid_result)) {
                        $resultFound = true;
                        break;
                    }
                }
                if($resultFound) {
                    break;
                }
            }
        }
		else{
			$resultFound = true;
		}
        if(!$resultFound) {
            return null;
        }

        $address = null;
        if (is_array($valid_result)) {
            $address = $valid_result[0];
        } else {
            $address = $valid_result;
        }

        $address_components = $address->address_components;
        if (!isset($address_components) || !is_array($address_components)) {
            return null;
        }
        $country = "";
        $city = "";
        $pointOfInterest = "";
        foreach ($address_components as $address_component) {
            if (isset($address_component->types) && is_array($address_component->types)) {
                $component_types = $address_component->types;
                if (in_array('country', $component_types)) {
                    $country = $address_component->long_name;
                }
                if (in_array('locality', $component_types)) {
                    $city = $address_component->long_name;
                }
                else if(in_array('point_of_interest', $component_types)) {
                    $pointOfInterest = $address_component->long_name;
                }
            }
        }

        if($city) {
            $return[] = $city;
        }
        if($pointOfInterest) {
            $return[] = $pointOfInterest;
        }
        if($country) {
            $return[] = $country;
        }
        return $return;
    }

    private function getCombinations($base, $n){
        $baselen = count($base);
        if($baselen == 0){
            return;
        }
        if($n == 1){
            $return = array();
            foreach($base as $b){
                $return[] = array($b);
            }
            return $return;
        }else{
            //get one level lower combinations
            $oneLevelLower = $this->getCombinations($base,$n-1);

            //for every one level lower combinations add one element to them that the last element of a combination is preceeded by the element which follows it in base array if there is none, does not add
            $newCombs = array();

            foreach($oneLevelLower as $oll){

                $lastEl = $oll[$n-2];
                $found = false;
                foreach($base as  $key => $b){
                    if($b == $lastEl){
                        $found = true;
                        continue;
                        //last element found

                    }
                    if($found == true){
                        //add to combinations with last element
                        if($key < $baselen){

                            $tmp = $oll;
                            $newCombination = array_slice($tmp,0);
                            $newCombination[]=$b;
                            $newCombs[] = array_slice($newCombination,0);
                        }

                    }
                }

            }

        }
        return $newCombs;
    }


    private function getFinalResults($info) {
        $past = $pop = $places = array();
        $results = $info['results'];	
        foreach ($results as $result) {
            foreach($result as $res) {
                if($res['filter'] == "past") {
                    if(empty($past) && $res['description']) {
                        $past['title'] = $res['title'];
                        $past['filter'] = $res['filter'];
                        $past['description'] = $res['description'];
                    }
                    if(strpos($res['title'], "Wikipedia") != -1) {
                        $past['title'] = $res['title'];
                        $past['filter'] = $res['filter'];
                        $past['description'] = $res['description'];
                        break;
                    }
                }
                else if($res['filter'] == "place") {
                    if($past['title'] != $res['title'] && substr($past['description'], 0, 20) != substr($res['description'], 0, 20) && $res['description']) {
                        $place['title'] = $res['title'];
                        $place['filter'] = $res['filter'];
                        $place['description'] = $res['description'];
						$places[] = $place;
                        break;
                    }
                }
                else {
                    if($past['title'] != $res['title'] && $places['title'] != $res['title']
                        && substr($past['description'], 0, 20) != substr($res['description'], 0, 20) && substr($places['description'], 0, 20) != substr($res['description'], 0, 20)
                        && $res['description']) {
                        $pop['title'] = $res['title'];
                        $pop['filter'] = $res['filter'];
                        $pop['description'] = $res['description'];
                        break;
                    }
                }
            }
        }
//        $info['results']['places'] = $info['results']['places'];

        $result["places1"] = array(
            "philter"=>$places[0]['filter'],
            "description"=>$places[0]['description'],
        );
	
		$result["places2"] = array(
            "philter"=>$places[1]['filter'],
            "description"=>$places[1]['description'],
        );


        $result["past"] = array(
            "philter"=>$past['filter'],
            "description"=>$past['description'],
        );


        $result["pop"] = array(
            "philter"=>$pop['filter'],
            "description"=>$pop['description'],
        );
        if ($places[0]['description'] != null) {
            $inf[] = $result["places1"];
        }
			
		if ($places[1]['description'] != null) {
            $inf[] = $result["places2"];
        }

        if ($past['description'] != null) {
            $inf[] = $result["past"];
        }
        if ($pop['description'] != null) {
            $inf[] = $result["pop"];
        }

        $info = array_values($inf);
        return $info;
    }


    public function getImageLocation($image) {
        $im = new Imagick($image);
        $exifArray = $im->getImageProperties("exif:GPS*");
        if (!array_key_exists("exif:GPSLatitude", $exifArray)) {
            throw new Exception("no gps info in picture");
        }
        $latDMS = $exifArray["exif:GPSLatitude"];
        $lonDMS = $exifArray["exif:GPSLongitude"];
        // var_dump(explode(",", $latDMS));
        list($dlat, $mlat, $slat) = (explode(",", $latDMS));
        list($dlon, $mlon, $slon) = (explode(",", $lonDMS));
        // echo "dlat:".((int)$dlat)."<br>";
        // echo "mlat:".((int)$mlat)."<br>";
        // echo "slat:".((int)$slat/100)."<br>";
        // var_dump($exifArray);
        $latsign = 1;
        $lonsign = 1;
        if($dlat < 0)  { $latsign = -1; }
        if($dlon < 0)  { $lonsign = -1; }

        $lat = $latsign * Util::DMStoDEC($dlat, $mlat, $slat);
        $lon = $lonsign * Util::DMStoDEC($dlon, $mlon, $slon);
        // var_dump($lat);
        // var_dump($lon);

        //http://maps.googleapis.com/maps/api/geocode/json?latlng=40.1875,44.513889&sensor=false
        $url = "http://maps.googleapis.com/maps/api/geocode/json?latlng=".$lat.",".$lon."&sensor=false";
        $options = array(
            CURLOPT_URL             => $url,
            CURLOPT_POST            => false,
            CURLOPT_RETURNTRANSFER  => true,
            CURLOPT_SSL_VERIFYPEER  => false
        );

        $curl = curl_init();
        curl_setopt_array($curl, $options);

        $response = curl_exec($curl);
//        $info = curl_getinfo($curl);
        $geolocation = json_decode($response);
        $results = $geolocation->results;
		
        $locations = [];
		
        foreach ($results as $key => $locality) {
            $locations[$locality->types[0]] = $locality->formatted_address;
        }
        return $locations;
    }


}

?>
