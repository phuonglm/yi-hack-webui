<?php
require_once('libs/utils.php');
require_once 'vendor/autoload.php';

if( $module == 'index'){
    $smarty = new Smarty;
    $smarty->assign("doc_title", "Yi Ant Camera", true);
    $smarty->display('index.tpl');
}
?>
