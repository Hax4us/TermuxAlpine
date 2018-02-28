#!/data/data/com.termux/files/usr/bin/bash
# Copyright ©2018 by Hax4Us. All rights reserved.🗺
#
# https://hax4us.com
################################################################################

# colors

red='\033[1;31m'
yellow='\033[1;33m'
blue='\033[1;34m'
reset='\033[0m'

#  url's of all possibls architectures

urlaarch64="http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/aarch64/alpine-minirootfs-3.7.0-aarch64.tar.gz"
urlarm="http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/armhf/alpine-minirootfs-3.7.0-armhf.tar.gz"
urlx86="http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86/alpine-minirootfs-3.7.0-x86.tar.gz"
urlx86_64="http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/alpine-minirootfs-3.7.0-x86_64.tar.gz"


# Destination

if [ -d $HOME/TermuxAlpine ]
	then
		rm -rf $HOME/TermuxAlpine
mkdir $HOME/TermuxAlpine
DESTINATION=$HOME/TermuxAlpine
else
	mkdir $HOME/TermuxAlpine
	DESTINATION=$HOME/TermuxAlpine
	fi
cd $DESTINATION
printrerunerror="Sorry :( to say your downloaded linux file was corrupted or half downloaded but dont worry just rerun my script"

# utility function for SHA

setsha() {
	SETSHA=.sha256
}

# utility function to initialize arch

getarch() {
	SETARCH=$1
}

# Utility function to check integrity

checkintegrity() {
	integritycheck=PASS
	echo
	printf "$blue [*] Checking integrity of file ..."
	echo
	echo " [*] Script will be terminate immediately in case of integrity failure"
	if [ $SETARCH = "aarch64" ]
		then
	sha256sum -c alpine-minirootfs-3.7.0-aarch64.tar.gz.sha256 && echo || integritycheck=FAIL
	if [ $integritycheck = "FAIL" ] 
		then
			printf "$red $printrerunerror $reset"
			exit
		else
			extract
		fi
			elif [ $SETARCH = "x86" ]
				then
	sha256sum -c alpine-minirootfs-3.7.0-x86.tar.gz.sha256 && echo "" || integritycheck=FAIL
	if [ $integritycheck = "FAIL" ] 
		then
			printf "$red $printrerunerror $reset"
			exit
		else
			extract
			fi
			elif [ $SETARCH = "x86_64" ]
				then
	sha256sum -c alpine-minirootfs-3.7.0-x86_64.tar.gz.sha256 && echo "" || integritycheck=FAIL
	if [ $integritycheck = "FAIL" ]
		then
			printf "$red $printrerunerror $reset"
			exit
		else
			extract
			fi
			elif [ $SETARCH = "armhf" ]
				then
		sha256sum -c alpine-minirootfs-3.7.0-armhf.tar.gz.sha256 && echo "" || integritycheck=FAIL
		if [ $integritycheck = "FAIL" ]
			then
				printf"$red $printrerunerror $reset"
				exit
			else
			extract
				fi

			fi
}

# Utility function to get tar file

gettarfile() {
	cd $DESTINATION
	printf "$blue [*] Getting tar file ...$reset"
	echo
	if [ $SETARCH = "aarch64" ]
		then
			URL=$urlaarch64	
		echo
			curl --progress-bar -L --fail --retry 4 -O "$URL"
		setsha
		getsha
			checkintegrity
	
elif [ $SETARCH = "armhf" ]
		then
			URL=$urlarm
		echo
			curl --progress-bar -L --fail --retry 4 -O "$URL"
			setsha
			getsha
			checkintegrityi
			elif [ $SETARCH = "x86" ]
				then
                	URL=$urlx86
	echo
     curl --progress-bar -L --fail --retry 4 -O "$URL"
     setsha
     getsha
     checkintegrity
	elif [ $SETARCH = "x86_64" ]
				then
                	URL=$urlx86_64
	echo
     curl --progress-bar -L --fail --retry 4 -O "$URL"
     setsha
     getsha
     checkintegrity
fi
}

# Utility function for Unknown Arch

unknownarch() {
	printf "$red"
	echo "[*] Unknown Architecture :("
	printf "$reset"
	exit
}

# Utility function for detect system

checksysinfo() {

	if [ $(getprop ro.product.cpu.abi) = "arm64-v8a" ]
		then
			checkdeps
			getarch aarch64
			gettarfile
		elif [ $(getprop ro.product.cpu.abi) = "armeabi" ]; then 
			checkdeps
			getarch armhf
			gettarfile
		elif [ $(getprop ro.product.cpu.abi) = "armeabi-v7a" ]; then
    		checkdeps
			getarch armhf
			gettarfile
		elif [ $(getprop ro.product.cpu.abi) = "x86" ]; then
			checkdeps
			getarch x86
			gettarfile 
		elif [ $(getprop ro.product.cpu.abi) = "x86_64" ]; then
			checkdeps
			getarch x86_64
			gettarfile
		else
			unknownarch
		fi
	}

# Utility function for login file

createloginfile() {
bin=$PREFIX/bin/startalpine
	cat > $bin <<- EOM
		#!/data/data/com.termux/files/usr/bin/bash -e
			unset LD_PRELOAD
				exec proot --link2symlink -0 -r $HOME/TermuxAlpine/ -b /dev/ -b /sys/ -b /proc/ -b /storage/ -b $HOME -w $HOME /usr/bin/env -i HOME=/root TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/sh --login
				EOM
chmod 700 $bin

}

# Utility function to extract tar file

extract() {
	printf "$blue [*] Extracting ... $reset"
	echo
	echo
	cd $DESTINATION
	OUTPUT=`ls | sed -n 1'p'`
	proot --link2symlink -0 bsdtar -xpf $OUTPUT 2> /dev/null || :
createloginfile
}

checkdeps() {
	printf "$blue \n"
	echo " [*] Updating termux ..."
	apt update -y &> /dev/null
	echo " [*] Checking all required tools ..."
	if [ -e $PREFIX/bin/proot ]
		then
			echo "  • Proot is OK"
		else
			apt install proot &> /dev/null
	if [ ! -e $PREFIX/bin/proot ]
		then
			printf "$red \n"
		echo " ERROR : check your internet connection or apt"
		printf "\n"
		echo " Exiting ..."
		printf "$reset"
		exit
		fi
	
			fi
	if [ -e $PREFIX/bin/bsdtar ]
		then
			echo "  • Bsdtar is Ok"
		else
			apt install bsdtar -y &> /dev/null
			if [ ! -e $PREFIX/bin/bsdtar ]
				then
					printf "$red"
		echo " ERROR : check your internet connection or apt"
		echo " [*] Exiting ..."
		printf "$reset"
		sleep 1
		exit
		fi
		fi
	if [ -e $PREFIX/bin/curl ]
		then
			echo "  • Curl is OK"
		else
			apt install curl -y &> /dev/null
			if [ ! -e $PREFIX/bin/curl ]
				then
	printf "$red"
	echo " ERROR : check your internet connection or apt "

  echo " Exiting ..."
  printf "$reset"
exit
				fi
				fi
}

# Utility function to get SHA

getsha() {
	echo
	printf "$blue [*] Getting SHA ... $reset"

	echo
	echo
	cd $DESTINATION
	if [ $SETARCH = "aarch64" ]
		then
		curl --progress-bar -L --fail --retry 4 -O "$URL$SETSHA"
	elif [ $SETARCH = "arm" ]
		then
	curl --progress-bar -L --fail --retry 4 -O "$URL$SETSHA"
	elif [ $SETARCH = "x86" ]
		then
		curl --progress-bar -L --fail --retry 4 -O "$URL$SETSHA"
	elif [ $SETARCH = "x86_64" ]
		then
		curl --progress-bar -L --fail --retry 4 -O "$URL$SETSHA"
	fi

}

# Utility function to touchup Alpine

finalwork() {
	if [ ! -e $HOME/finaltouchup.sh ] 
		then
	
	curl --silent -LO https://raw.githubusercontent.com/Hax4us/TermuxAlpine/master/finaltouchup.sh
	. finaltouchup.sh
else
	. finaltouchup.sh
	fi
}

# Start
clear
echo
printf "$yellow You are going to install Alpine in termux ;) Cool"
echo
printf " Only 1mb ? Yes "
echo
echo
printf "$blue [*] Checking host architecture ..."
checksysinfo
printf "$blue [*] Configuring Alpine For You ..."
cd && finalwork
printf "$blue"
echo
echo " #-----------------------------------------------#"
echo
printf "$yellow Now you can enjoy very small linux just 1 MB environment in your TERMUX :)\n Dont forget to like my hard work against termux and many other things"
printf "$blue"
echo
echo
echo " #-----------------------------------------------#"
echo
echo " #-----------------------------------------------#"
echo
printf "$blue [∆] My Official Mail : $yellow lokesh@hax4us.com"
echo
printf "$blue [∆] My Website       : $yellow https://hax4us.com"
echo
printf "$blue [∆] My Channel       : $yellow https://youtube.com/hax4us $reset"
printf "$blue"
echo
echo " #-----------------------------------------------#"
printf "$reset"
