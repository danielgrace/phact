<?php
class Util
{
    /**
     * Format phone number according to country rules
     *
     * @param string $phoneNumber
     * @return string - formatted phone number
     */
    public static function formatPhone($phoneNumber)
    {
        // Format US number
        $phoneNumber = preg_replace("/^1{1,}/", "1", $phoneNumber);
        
        // Format UK number
        $phoneNumber = preg_replace("/^440{1,}/", "44", $phoneNumber);

        return $phoneNumber;
    }

    /**
     * convert phone-number to username according to country rules
     * IMPORTANT this method should be ran only after formatPhone
     * @param string $phoneNumber
     * @return string - formatted phone number
     */
    public static function formatUsername($phoneNumber)
    {
        // Format US number
        $phoneNumber = preg_replace("/^1{1}/", "11", $phoneNumber);

        // Format UK number
        $phoneNumber = preg_replace("/^44{1}/", "440", $phoneNumber);

        return $phoneNumber;
    }

    /**
     * Validate phone number
     *
     * @param string $phoneNumber
     * @throws PhactException
     */
    public static function isPhoneNumberValid($phoneNumber, $checkLength = true)
    {
        $isNumeric = ctype_digit($phoneNumber);
        if ($checkLength && strlen($phoneNumber) < 8) {
            throw new PhactException(PhactMsg::INVALID_PHONE);
        }
        if ($phoneNumber === '' || !$isNumeric) {
            throw new PhactException(PhactMsg::INVALID_PHONE);
        }
    }

    /**
     * Extract application data
     * from the User-Agent string:
     *
     * application name (e.g. AvtiPhone)
     * application version (e.g. 1.2.1)
     * type (application|browser)
     * device name (e.g. Android)
     * full device name (e.g. Android)
     *
     * @param string $ua - HTTP User-Agent Request header
     * @return mixed - extracted app data as object
     */
    public static function extractAppData($ua)
    {
        $data = new stdClass;

        $data->name           = null;
        $data->version        = null;
        $data->type           = null;
        $data->device         = null;
        $data->fullDevice     = null;
        $data->appFullName    = null;

        $deviceList = array(
            'Android',
            'iPad',
            'iPod',
            'iPhone',
            'BlackBerry'
        );

        $pattern = '/[\s\/\(]/';
        $chunks = preg_split($pattern, $ua, 3);

        $data->name = $chunks[0];

        if (isset($chunks[1])) {
            $data->version = (int)str_replace('.', '', $chunks[1]);
        }

        $data->type = ($data->name === 'Phact')
                    ? 'application'
                    : 'browser';

        if (isset($chunks[2])) {
            $deviceInfo = substr(
                $chunks[2],
                1,
                strpos($chunks[2], ')') - 1
            );

            foreach ($deviceList as $deviceName) {
                if (strpos($deviceInfo, $deviceName) !== false) {
                    $data->device = $deviceName;
                    break;
                }
            }

            $data->fullDevice = $deviceInfo;
            $data->appFullName = $data->name . '_' . $data->device;
        }

        return $data;
    }

    public static function sendServiceMail($to, $subject, $body, $isHTML = true)
    {
        $headers = "From: Phact <no-reply@phact.me>\r\n";
        $headers .= "Reply-To: no-reply@phact.me\r\n";

        if ($isHTML) {
            $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
        }

        $headers .= 'X-Mailer: PHP/' . phpversion();

        $to = array_filter($to);
        $to = implode(', ', $to);

        return mail($to, $subject, $body, $headers);
    }

    /**
     * format $ 4.567678 will return 4.567, just cutting 3 numbers
     * @param $number
     * @return float
     */
    public static function formatNumber($number) {
        $n =(string) $number;
        $ind = strrpos($n, ".");
        return floatval(substr($n, 0, ($ind+4)));

    }

    public static function saveImage($data, $dataType="url", $folder = "personal", $mediaDir = '/tmp/') {
        $mediaDir = $mediaDir."/".$folder."/";
        if (!is_dir($mediaDir)) {
            mkdir($mediaDir);
        }
        $destinationDir = $mediaDir . rand(0 , 100);
        if (!is_dir($destinationDir)) {
            mkdir($destinationDir);
        }

        if ($dataType == "url") {
            $imageNameSplit = preg_split("/\//", $data);
            $pattern = "/(\.\w{2,4})$/";
            $replacement = time().'$1';
            $filenameTemplate = preg_replace($pattern, $replacement, $imageNameSplit[count($imageNameSplit)-1]);
        } else {
            $filenameTemplate = preg_replace("/\./", "_", preg_replace("/\s/", "_", microtime())).".png";
        }
        $fileName = $destinationDir . '/'.$filenameTemplate ;
//        var_dump($fileName);exit;
        //$gzFileData = base64_decode($imageData);
        //$data = $this->decompress($gzFileData);
        if ($dataType == "url") {
            $im = file_get_contents($data); //$data;
        } elseif ($dataType == "base64") {
            $im = base64_decode($data); //$data;
        }
        try {
            $file = fopen($fileName, "w");
            fwrite($file, $im);
            fclose($file);
//     /Users/garik/Projects/Phact/phact/Phact-API/public/images/data/personal/46/1509796_10152138538364573_1243024325_n1392374878.jpg
            $urlPattern = "/.*public\/images/";
            $publicUrl = preg_replace($urlPattern, "http://" . $_SERVER['SERVER_NAME'] . "/public/images", $fileName);
            return $publicUrl;
        } catch (Exception $e) {
            return $e->getMessage();
        }
    }

    public static function calc($equation)
    {
        // Remove whitespaces
        $equation = preg_replace('/\s+/', '', $equation);
        // echo "$equation\n";

        $number = '(?:-?\d+(?:[,.]\d+)?|pi|π)'; // What is a number
        $functions = '(?:sinh?|cosh?|tanh?|abs|acosh?|asinh?|atanh?|exp|log10|deg2rad|rad2deg|sqrt|ceil|floor|round)'; // Allowed PHP functions
        $operators = '[+\/*\^%-]'; // Allowed math operators
        $regexp = '/^(('.$number.'|'.$functions.'\s*\((?1)+\)|\((?1)+\))(?:'.$operators.'(?1))?)+$/'; // Final regexp, heavily using recursive patterns

        if (preg_match($regexp, $equation))
        {
            $equation = preg_replace('!pi|π!', 'pi()', $equation); // Replace pi with pi function
            // echo "$equation\n";
            eval('$result = '.$equation.';');
        }
        else
        {
            $result = false;
        }
        return $result;
    }

    public static function DMStoDEC($deg,$min,$sec)
    {
        return (self::calc($sec)/60+self::calc($min))/60+self::calc($deg);
    }


}
?>