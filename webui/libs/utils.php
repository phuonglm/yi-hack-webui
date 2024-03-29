<?php
$GLOBALS['DATA_DIR'] = getenv("DATA_PATH") ? getenv("DATA_PATH") : "data/";
#date_default_timezone_set(getenv("TIME_ZONE") ? getenv("TIME_ZONE") : "UTC");
date_default_timezone_set("UTC");
$GLOBALS['HOTLINK_SECRET'] = getenv("HOTLINK_SECRET") ? getenv("HOTLINK_SECRET") : "hellosecret";
$GLOBALS['HOTLINK_TTL'] = getenv("HOTLINK_TTL") ? getenv("HOTLINK_TTL") : 3600;

$tzOffset= new DateTime('now', new DateTimeZone(getenv("TIME_ZONE") ? getenv("TIME_ZONE") : "UTC"));
$TIME_OFFSET = $tzOffset->format('Z')*1000;

class Segment {
    public $start;
    public $end;

    public function __construct($start, $end) {
        $this->start = $start;
        $this->end = $end;
    }

    public function getPlayList(){
        $playlist = [];
        $current = $this->start;
        while ($current < $this->end ){
            array_push($playlist, Utils::createPath($current));
            $current->modify("+1 minutes");
        }
        return $playlist;
    }
};

class TimeLine {
    private $basePath;

    public function __construct($basePath) {
        $this->basePath = $basePath;
    }
    public function getRange($start, $end){
        $segments = [];
        $recordList = Utils::getRecordList($this->basePath, $start, $end);
        $endTime = $start;
        foreach ($recordList as $record) {
            $startTime = Utils::createDate($record);
            if($startTime > $endTime){
                $endTime = Utils::findEnd($this->basePath, $record);
                // echo Utils::createPath($startTime)." ~> ". Utils::createPath($endTime)."\n";
                $segment = new Segment($startTime, $endTime);
                array_push($segments, $segment);
            } else {
                continue;
            }
        }
        return $segments;
    }
}

class Utils{
    public static function getRecordList($basePath, $start, $end){
        if (is_dir($GLOBALS['DATA_DIR'].$basePath)) {
            $dirList = [];
            if ($dh = opendir($GLOBALS['DATA_DIR'].$basePath)) {
                while (($file = readdir($dh)) !== false) {
                    if(filetype($GLOBALS['DATA_DIR'].$basePath . '/' . $file) == 'dir' &&
                        DateTime::createFromFormat('Y\Ym\Md\DH\H',$file) >= DateTime::createFromFormat('Y\Ym\Md\DH\H',$start->format('Y\Ym\Md\DH\H')) &&
                        DateTime::createFromFormat('Y\Ym\Md\DH\H',$file) <= DateTime::createFromFormat('Y\Ym\Md\DH\H',$end->format('Y\Ym\Md\DH\H'))){
                        array_push($dirList, $file);
                    }
                }
                closedir($dh);
            }
            sort($dirList);
            $recordList = [];
            foreach ($dirList as $recordDir) {
                if ($dh = opendir($GLOBALS['DATA_DIR'].$basePath."/".$recordDir)) {
                    while (($file = readdir($dh)) !== false) {
                        $recordPath = $recordDir.'/'.$file;
                        $recordDate = Utils::createDate($recordPath);

                        if(filetype($GLOBALS['DATA_DIR'].$basePath. '/' .$recordDir.'/'.$file) == 'file' &&
                            $recordDate >= $start &&
                            $recordDate <= $end){
                            array_push($recordList, $recordPath);
                        }
                    }
                    closedir($dh);
                }
            }
            sort($recordList);
            return $recordList;
        }
    }

    public static function createDate($path){
        return DateTime::createFromFormat('Y\Ym\Md\DH\H/i\Ms\S\.\m\p\4',$path);
    }

    public static function createPath($date){
        return $date->format('Y\Ym\Md\DH\H/i\Ms\S\.\m\p\4');
    }

    public static function createFullPath($basePath, $date){
        return $GLOBALS['DATA_DIR']."$basePath".$date->format('Y\Ym\Md\DH\H/i\Ms\S\.\m\p\4');
    }

    public static function findStart($basePath, $path){
        $inputDate = Utils::createDate($path);
        $startTime = $inputDate;
        while(file_exists(
            Utils::createFullPath($basePath,
                            $startTime->modify('-1 minutes'))
            ))
        {
            // Do nothing
        }
        return $startTime->modify('+1 minutes');
    }

    public static function findEnd($basePath, $path){
        $inputDate = Utils::createDate($path);
        $endTime = $inputDate;

        if($endTime->getTimestamp()%60 != 0){
            $endTime->modify('+'.(60-($endTime->getTimestamp()%60)).' seconds');
        } else {
            $endTime->modify('+1 minutes');
        }

        while(file_exists(

            Utils::createFullPath( $basePath, $endTime)
            ))
        {
            $endTime->modify('+1 minutes');
        }
        return $endTime;
    }

    public static function getSegment($basePath, $path){
        if(file_exists($GLOBALS['DATA_DIR'].$basePath.$path)){
            $result = new Segment(Utils::findStart($basePath, $path), Utils::findEnd($basePath, $path));
        } else {
            $result = null;
        }
        return $result;
    }
}

function getData(){
    if(isset($_GET['r'])){
        $endDate = new DateTime();
        $startDate = new DateTime();
        $startDate->modify("-".$_GET['r']." days");
    } elseif (isset($_GET['d'])){
        $startDate = new DateTime();
        $startDate->setTimestamp(intval($_GET['d']/1000));

        $endDate = new DateTime();
        $endDate->setTimestamp(intval($_GET['d']/1000));
        $endDate->modify("+1 days");
    }

    $data = new stdClass();
    $data->cols = array(
                    array('type'=> 'string', 'id'=> 'Camera'),
                    array('type'=> 'datetime', 'id'=> 'Start'),
                    array('type'=> 'datetime', 'id'=> 'End')
                );
    $data->rows = array();
    $hostsname = explode(" ", getenv('CAMERAS'));
    foreach ($hostsname as $hostname) {
        $timeLine = new TimeLine($hostname.'/');
        $records = $timeLine->getRange($startDate,
                                       $endDate);
        foreach ($records as $record) {
            array_push($data->rows, array('c' => array(
                                        array('v' => $hostname),
                                        array('v' => $record->start->getTimestamp()*1000),
                                        array('v' => $record->end->getTimestamp()*1000)))
            );
        }
    }
    echo json_encode($data);
};

function path_hash($path, $expires, $secret){
  $expires = time() + $expires;
  $md5 = md5("$expires$path $secret", true);
  $md5 = base64_encode($md5);
  $md5 = strtr($md5, '+/', '-_');
  $md5 = str_replace('=', '', $md5);
  return $path . '?md5=' . $md5 . '&expires=' . $expires;
}

function getPlaylist(){

    $base = $_GET['base'];
    $start = new DateTime();
    $start->setTimestamp( intval($_GET['start']/1000));

    $end = new DateTime();
    $end->setTimestamp(intval($_GET['end']/1000));
    $playlist = Utils::getRecordList($base, $start, $end);

    $protocol = "http";
    if(isset($_SERVER['HTTP_X_FORWARDED_SCHEME'])){
      $protocol = $_SERVER['HTTP_X_FORWARDED_SCHEME'];
    }
    if ($_GET['type'] == 'm3u'){
        header("content-type: audio/x-mpegurl");
        echo "#EXTM3U \r\n";
        foreach ($playlist as $media) {
            echo $protocol."://".$_SERVER['HTTP_HOST'] . path_hash('/data/' . $base . '/' . $media, $GLOBALS['HOTLINK_TTL'], $GLOBALS['HOTLINK_SECRET']) . "\r\n";
        }
    } elseif ($_GET['type'] == 'json') {
        $result = array();
        foreach ($playlist as $media) {
            $fullUrl = $protocol."://".$_SERVER['HTTP_HOST'] . path_hash('/data/' . $base . '/' . $media, $GLOBALS['HOTLINK_TTL'], $GLOBALS['HOTLINK_SECRET']);
            array_push($result, $fullUrl);
        }
        echo json_encode($result);
    }
};

function deletePlaylist(){
    $base = $_GET['base'];
    $start = new DateTime();
    $start->setTimestamp( intval($_GET['start']/1000));

    $end = new DateTime();
    $end->setTimestamp(intval($_GET['end']/1000));
    $playlist = Utils::getRecordList($base, $start, $end);

    $protocol = explode("/",$_SERVER['SERVER_PROTOCOL']);
    $protocol = strtolower(array_shift($protocol));

    foreach ($playlist as $media) {
        unlink ($GLOBALS['DATA_DIR'].$base."/".$media);
    }
    echo '{"status":"ok"}';
}

$module = "";
if (isset($_GET['a']) && $_GET['a'] == 'getData'){
    getData();
} elseif (isset($_GET['a']) && $_GET['a'] == 'getPlaylist') {
    getPlaylist();
} elseif (isset($_GET['a']) && $_GET['a'] == 'deletePlaylist') {
    deletePlaylist();
} else {
    $module = "index";
}
?>
