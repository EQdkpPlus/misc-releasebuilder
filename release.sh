#!/bin/sh
varInstaller=https://raw.githubusercontent.com/EQdkpPlus/tool-zipinstaller/master/install.php
varGitRepo=https://github.com/EQdkpPlus/core.git
varGitArchive=https://github.com/EQdkpPlus/core/archive/

# Remove some folders
rm /home/eqdkp2/_release/zips/ -Rf
rm /home/eqdkp2/_release/tmp/ -Rf
rm /home/eqdkp2/_release/latesttag/ -Rf
rm /home/eqdkp2/_release/tags/ -Rf

# Create some folders
mkdir /home/eqdkp2/_release/
mkdir /home/eqdkp2/_release/tmp/
mkdir /home/eqdkp2/_release/latesttag/

# Download Installer
wget $varInstaller
mv install.php /home/eqdkp2/_release/tmp

lastTag=`git ls-remote -t ${varGitRepo} | awk '{print $2}' | cut -d '/' -f 3 | cut -d '^' -f 1  | uniq | sort -V | tail -1`

if [ -z "$1" ]
  then
    echo "No arguments supplied";
  else
	lastTag=$1;
fi

lastTagNumber=${lastTag//v}
echo ${lastTagNumber}

# Download latest Tag
wget ${varGitArchive}${lastTag}.tar.gz
# Extract
tar -xzf ${lastTag}.tar.gz -C /home/eqdkp2/_release/latesttag/
rm ${lastTag}.tar.gz

# get Subdir
cd /home/eqdkp2/_release/latesttag/
varSubDir=`ls | awk '{print $1}' | grep ${lastTagNumber}`

# Delete unneccessary files
cd /home/eqdkp2/_release/latesttag/${varSubDir}/
rm -rf tests/
rm -rf .github/
rm .gitattributes
rm .gitignore
rm .travis.yml

find /home/eqdkp2/_release/latesttag/${varSubDir}/ -type f  > /home/eqdkp2/_release/latesttag/${varSubDir}/__files.txt
cd /home/eqdkp2/_release/latesttag/${varSubDir}/

zip -r eqdkp_plus.zip *
mv eqdkp_plus.zip /home/eqdkp2/_release/tmp/
cd /home/eqdkp2/_release/tmp/
zip -r eqdkp-plus_${lastTagNumber}_fullpackage.zip *
mkdir /home/eqdkp2/_release/zips/
mv eqdkp_plus.zip /home/eqdkp2/_release/zips/eqdkp-plus_${lastTagNumber}_core.zip

mv /home/eqdkp2/_release/tmp/eqdkp-plus_${lastTagNumber}_fullpackage.zip /home/eqdkp2/_release/zips/

echo The Files are stored to /home/eqdkp2/_release/zips/

php /home/eqdkp2/shell/release_git/checkversion.php ${lastTagNumber} ${varSubDir}
exitcode=$?

if [ ${exitcode} = 42 ]
	then
		echo "Version mismatch from LatestTag and latest Release!!!";
		exit;
fi
echo Now the Update Packages
/bin/sh /home/eqdkp2/shell/release_git/packages.sh $1

rm /home/eqdkp2/_release/tmp/ -Rf
rm /home/eqdkp2/_release/latesttag/ -Rf
rm /home/eqdkp2/_release/tags/ -Rf