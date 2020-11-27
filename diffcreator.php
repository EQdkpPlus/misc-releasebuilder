<?php

	$tag = $argv[1];
	$latestTag = $argv[3];
	
	$latestTagSubdir = $argv[4];
	$tagSubDir = $argv[2];
	
	$folder = "/home/eqdkp2/_release/tags/";
	$newPath = "/home/eqdkp2/_release/latesttag/".$latestTagSubdir.'/';
	//$newPath = "/home/eqdkp2/_release/latesttag/";
	$oldPath = "/home/eqdkp2/_release/tags/".$tag.'/'.$tagSubDir.'/';
	
	if ($tag == $latestTag) return;

	$strOldFiles = file_get_contents($oldPath.'/__files.txt');
	$strNewFiles = file_get_contents($newPath."/__files.txt");
		
	$arrNewFiles = explode("\n", $strNewFiles);
	$arrOldFiles = explode("\n", $strOldFiles);
	
	foreach($arrNewFiles as $file){
		$arrNewFilesClean[] = clean_string($file, "latesttag", $latestTagSubdir);
	}
	
	foreach($arrOldFiles as $file){
		$arrOldFilesClean[] = clean_string($file, $tag, $tagSubDir);
	}
	
	$xml = '<?xml version="1.0" encoding="UTF-8" standalone="no"?><files>';

	
	//Removed Files
	$arrRemovedFiles = array_diff($arrOldFilesClean, $arrNewFilesClean);
	$arrRemovedFiles = array();
	$arrRemoved = array();
	foreach($arrRemovedFiles as $file){
		$arrRemoved[] = array(
			'file' => $file,
			'name' => $file,
			'type' => 'removed',
			'md5' => md5_file($oldPath.$file),
			'md5_old' => md5_file($oldPath.$file),
		);
	}
	
	
	//New Files
	$arrNewCreatedFiles = array_diff($arrNewFilesClean, $arrOldFilesClean);
	$arrNew = array();
	foreach($arrNewCreatedFiles as $file){
		if ($file == "__files.txt") continue;
		if(!validateFile($file)) continue;
		
		$arrNew[] = array(
			'file' => $newPath.$file,
			'name' => $file,
			'type' => 'new',
			'md5' => md5_file($newPath.$file),
			'md5_old' => md5_file($newPath.$file),
		);
	}
	
	//Changed Files
	$arrChanged = array();
	foreach($arrNewFilesClean as $file){
		if ($file == "__files.txt") continue;
		if(!validateFile($file)) continue;
		
		$oldFile = $oldPath.$file;
		$newFile = $newPath.$file;
		
		if (is_file($oldFile) && md5_file($oldFile) != md5_file($newFile)){
			$arrChanged[] = array(
				'file' => $newFile,
				'name' => $file,
				'type' => 'changed',
				'md5' => md5_file($newFile),
				'md5_old' => md5_file($oldFile),
			);
		}
	}
	
	
	//Copy new and changed files
	$patchfolder = $folder."patches/".$tag."_".$latestTag."/";
	mkdir($folder."patches/");
	mkdir($patchfolder);
	

	foreach($arrChanged as $val){
		$path = pathinfo($patchfolder.$val['name'], PATHINFO_DIRNAME);
		mkdir($path, 0777, true);
		copy($val['file'], $patchfolder.$val['name']);
		
		$xml .= '<file name="'.$val['name'].'" type="'.$val['type'].'" md5="'.$val['md5'].'" md5_old="'.$val['md5_old'].'" />';
	}
	
	
	foreach($arrNew as $val){
		$path = pathinfo($patchfolder.$val['name'], PATHINFO_DIRNAME);
		mkdir($path, 0777, true);
		copy($val['file'], $patchfolder.$val['name']);
		
		$xml .= '<file name="'.$val['name'].'" type="'.$val['type'].'" md5="'.$val['md5'].'" md5_old="'.$val['md5_old'].'" />';
	}

	foreach($arrRemoved as $val){
		$xml .= '<file name="'.$val['name'].'" type="'.$val['type'].'" md5="'.$val['md5'].'" md5_old="'.$val['md5_old'].'" />';
	}
	
	$xml .= '</files>';

	file_put_contents($patchfolder.'package.xml', $xml);
	
	function validateFile($file){
		$arrFile = pathinfo($file);
		$strFilename = strtolower($arrFile['basename']);
		//Check Files
		$ignore = array('.git', '.gitignore', '.travis.yml', '.gitattributes', 'custom.css', 'custom.js');
		if(in_array($strFilename, $ignore)){
			return false;
		}
		$strDir = $arrFile['dirname'];
		//Check /tests/ Directory
		if(stripos($strDir, 'tests/') === 0 || stripos($strDir, '/tests/') === 0 || stripos($strDir, '/.github/') === 0 || stripos($strDir, '.github/') === 0){
			return false;
		}
		
		return true;
	}
	
	
	//Cleans Filename
	function clean_string($string, $tag, $subDir=""){
		if ($tag == "latesttag") {
			$folder = "/home/eqdkp2/_release/latesttag/".$subDir.'/';
		} else $folder = "/home/eqdkp2/_release/tags/".$tag.'/'.$subDir.'/';
		return str_replace($folder, "", $string);
	}
?>