#!/bin/bash
#set -e
##################################################################################################################
# Author	:	Andrey Zimin
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
buildFolder="$HOME/architect-build"
outFolder="$HOME/architect-complete"
package="archiso"

echo
echo "################################################################## "
tput setaf 2;echo "Checking if archiso is installed";tput sgr0
echo "################################################################## "
echo

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then
		echo "################################################################"
		echo "################## "$package" is already installed"
		echo "################################################################"
else
	#checking which helper is installed
	if pacman -Qi yay &> /dev/null; then
		echo "################################################################"
		echo "######### Installing with yay"
		echo "################################################################"
		yay -S --noconfirm $package
	elif pacman -Qi trizen &> /dev/null; then
		echo "################################################################"
		echo "######### Installing with trizen"
		echo "################################################################"
		trizen -S --noconfirm --needed --noedit $package
	fi
	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then
		echo "################################################################"
		echo "#########  "$package" has been installed"
		echo "################################################################"
	else
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "!!!!!!!!!  "$package" has NOT been installed"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		exit 1
	fi
fi

echo
echo "################################################################## "
tput setaf 2;echo "Moving files to build folder";tput sgr0
echo "################################################################## "
echo

echo "Copying files and folder to build folder as root"
sudo mkdir $buildFolder
sudo cp -r ../src/* $buildFolder

sudo chmod 750 $buildFolder/airootfs/etc/sudoers.d
sudo chmod 750 $buildFolder/airootfs/etc/polkit-1/rules.d
sudo chgrp polkitd $buildFolder/airootfs/etc/polkit-1/rules.d
sudo chmod 750 $buildFolder/airootfs/root

echo "adding time to /etc/dev-rel"
date_build=$(date -d now)
sudo sed -i "s/\(^ISO_BUILD=\).*/\1$date_build/" $buildFolder/airootfs/etc/dev-rel

cd $buildFolder

echo
echo "################################################################## "
tput setaf 2;echo "Cleaning the cache";tput sgr0
echo "################################################################## "
echo

yes | sudo pacman -Scc

echo
echo "################################################################## "
tput setaf 2;echo "Building the iso";tput sgr0
echo "################################################################## "
echo

sudo ./build.sh -v

echo
echo "################################################################## "
tput setaf 2;echo "Moving the iso to out folder";tput sgr0
echo "################################################################## "
echo

[ -d $outFolder ] || mkdir $outFolder
cp $buildFolder/out/arcolinuxb* $outFolder

echo
echo "################################################################## "
tput setaf 2;echo "Making sure we start with a clean slate next time";tput sgr0
echo "################################################################## "
echo
echo "Deleting the build folder if one exists - takes some time"
[ -d $buildFolder ] && sudo rm -rf $buildFolder
