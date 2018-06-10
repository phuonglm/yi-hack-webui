<?php
require_once('libs/utils.php');
require_once 'vendor/autoload.php';

if( $module == 'index'){
    $smarty = new Smarty;
    $smarty->assign("doc_title", "Yi Ant Camera", true);
    $smarty->assign("devices",explode(" ",getenv("CAMERAS")));
    $smarty->display('index.tpl');
}
?>
