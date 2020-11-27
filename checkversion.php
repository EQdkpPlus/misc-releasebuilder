<?php
	$latestTag = $argv[1];
	$latestTagSubDir = $argv[2];
	
	$newPath = "/home/eqdkp2/_release/latesttag/".$latestTagSubDir."/";
	define('EQDKP_INC', true);
	include_once($newPath.'/core/constants.php');

	if(VERSION_EXT != $latestTag){
		exit(42);
	}