#!/bin/sh
varInstaller=https://raw.githubusercontent.com/EQdkpPlus/tool-zipinstaller/master/install.php
varGitRepo=https://github.com/EQdkpPlus/core.git
varGitArchive=https://github.com/EQdkpPlus/core/archive/
varNumberPackages=35

lastTag=`git ls-remote -t ${varGitRepo} | awk '{print $2}' | cut -d '/' -f 3 | cut -d '^' -f 1  | uniq | sort -V | tail -1`

if [ -z "$1" ]
  then
    echo "No arguments supplied";
  else
	lastTag=$1;
fi

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }


lastTagNumber=${lastTag//v}
varlastTagSubDir=`ls /home/eqdkp2/_release/latesttag/ | awk '{print $1}' | grep ${lastTagNumber}`

rm /home/eqdkp2/_release/zips/Update_Packages/ -rf
mkdir /home/eqdkp2/_release/zips/Update_Packages/
mkdir /home/eqdkp2/_release/tags/

lastTags=`git ls-remote -t ${varGitRepo} | awk '{print $2}' | cut -d '/' -f 3 | cut -d '^' -f 1  | uniq | sort -V -r | head -${varNumberPackages}`

for line in $lastTags;do
	echo Update Package for $line
	varTagName=${line//v}

	if [[ "$lastTagNumber" == "$varTagName" ]]; then
		continue
	fi
	
	
	if version_gt $varTagName $lastTagNumber; then
		continue
	fi
	
	echo ${varTagName}
	wget ${varGitArchive}${line}.tar.gz
	mkdir /home/eqdkp2/_release/tags/${varTagName}
	tar -xzf ${line}.tar.gz -C /home/eqdkp2/_release/tags/${varTagName}
	rm ${line}.tar.gz
	varSubDir=`ls /home/eqdkp2/_release/tags/${varTagName} | awk '{print $1}' | grep ${varTagName}`
	echo ${varSubDir}

	find /home/eqdkp2/_release/tags/${varTagName}/${varSubDir}/ -type f  > /home/eqdkp2/_release/tags/${varTagName}/${varSubDir}/__files.txt

	php /home/eqdkp2/shell/release_git/diffcreator.php ${varTagName} ${varSubDir} ${lastTagNumber} ${varlastTagSubDir}
	
	#create zips, move to zip Folder
	rm /home/eqdkp2/_release/tags/${varTagName}/${varSubDir}/__files.txt
	cd /home/eqdkp2/_release/tags/patches/${varTagName}_${lastTagNumber}
	zip -r eqdkp-plus_${varTagName}_to_${lastTagNumber}_update.zip *
	echo Move Update Package eqdkp-plus_${varTagName}_to_${lastTagNumber}_update.zip
	mv eqdkp-plus_${varTagName}_to_${lastTagNumber}_update.zip /home/eqdkp2/_release/zips/Update_Packages/
	
	rm /home/eqdkp2/_release/tags/${varTagName}/ -Rf
done

echo Update Packages Finished