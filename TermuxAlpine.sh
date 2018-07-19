#!/data/data/com.termux/files/usr/bin/bash -e
# Copyright ©2018 by Hax4Us. All rights reserved.  🌎 🌍 🌏 🌐 🗺
#
# https://hax4us.com
################################################################################

# colors

red='\033[1;31m'
yellow='\033[1;33m'
blue='\033[1;34m'
reset='\033[0m'


# Destination

DESTINATION=${HOME}/TermuxAlpine
[ -d $DESTINATION ] && rm -rf $DESTINATION
mkdir $DESTINATION
cd $DESTINATION

# Utility function for Unknown Arch

unknownarch() {
	printf "$red"
	echo "[*] Unknown Architecture :("
	printf "$reset"
	exit 1
}

# Utility function for detect system

checksysinfo() {
	printf "$blue [*] Checking host architecture ..."
	case $(getprop ro.product.cpu.abi) in
		arm64-v8a)
			SETARCH=aarch64
			;;
		armeabi|armeabi-v7a)
			SETARCH=armhf
			;;
		x86)
			SETARCH=x86
			;;
		x86_64)
			SETARCH=x86_64
			;;
		*)
			unknownarch
			;;
	esac
}

# Check if required packages are present

checkdeps() {
	printf "${blue}\n"
	echo " [*] Updating apt cache..."
	apt update -y &> /dev/null
	echo " [*] Checking for all required tools..."

	for i in proot bsdtar curl; do
		if [ -e $PREFIX/bin/$i ]; then
			echo "  • $i is OK"
		else
			echo "Installing ${i}..."
			apt install -y $i || {
				printf "$red"
				echo " ERROR: check your internet connection or apt\n Exiting..."
				printf "$reset"
				exit 1
			}
		fi
	done
}

# URLs of all possibls architectures

seturl() {
	ALPINE_VER=$(curl -s http://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$SETARCH/latest-releases.yaml | grep -m 1 -o version.* | sed -e 's/[^0-9.]*//g' -e 's/-$//')
	if [ -z "$ALPINE_VER" ] ; then
		exit 1
	fi
	ALPINE_URL="http://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/$SETARCH/alpine-minirootfs-$ALPINE_VER-$SETARCH.tar.gz"
}

# Utility function to get tar file

gettarfile() {
	printf "$blue [*] Getting tar file...$reset\n\n"
	seturl $SETARCH
	curl --progress-bar -L --fail --retry 4 -O "$ALPINE_URL"
	rootfs="alpine-minirootfs-$ALPINE_VER-$SETARCH.tar.gz"
}

# Utility function to get SHA

getsha() {
	printf "\n${blue} [*] Getting SHA ... $reset\n\n"
	curl --progress-bar -L --fail --retry 4 -O "${ALPINE_URL}.sha256"
}

# Utility function to check integrity

checkintegrity() {
	printf "\n${blue} [*] Checking integrity of file...\n"
	echo " [*] The script will immediately terminate in case of integrity failure"
	printf ' '
	sha256sum -c ${rootfs}.sha256 || {
		printf "$red Sorry :( to say your downloaded linux file was corrupted or half downloaded, but don't worry, just rerun my script\n${reset}"
		exit 1
	}
}

# Utility function to extract tar file

extract() {
	printf "$blue [*] Extracting... $reset\n\n"
	proot --link2symlink -0 bsdtar -xpf $rootfs 2> /dev/null || :
}

# Utility function for login file

createloginfile() {
	bin=${PREFIX}/bin/startalpine
	cat > $bin <<- EOM
#!/data/data/com.termux/files/usr/bin/bash -e
unset LD_PRELOAD
# thnx to @j16180339887 for DNS picker
addresolvconf ()
{ 
  [ $(command -v getprop) ] && getprop | sed -n -e 's/^\[net\.dns.\]: \[\(.*\)\]/\1/p' | sed '/^\s*$/d' | sed 's/^/nameserver /' > $HOME/TermuxAlpine/etc/resolv.conf
}
addresolvconf
exec proot --link2symlink -0 -r ${HOME}/TermuxAlpine/ -b /dev/ -b /sys/ -b /proc/ -b /storage/ -b $HOME -w $HOME /usr/bin/env -i HOME=/root TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/sh --login
EOM

	chmod 700 $bin
}

# Utility function to touchup Alpine

finalwork() {
	[ ! -e ${HOME}/finaltouchup.sh ] && curl --silent -LO https://raw.githubusercontent.com/Hax4us/TermuxAlpine/master/finaltouchup.sh
chmod +x ${HOME}/finaltouchup.sh && ${HOME}/finaltouchup.sh
}



# Utility function for cleanup

cleanup() {
	if [ -d $DESTINATION ]; then
		rm -rf $DESTINATION
	else
		printf "$red not installed so not removed${reset}\n"
		exit
	fi
	if [ -e $PREFIX/bin/startalpine ]; then
		rm $PREFIX/bin/startalpine
		printf "$yellow uninstalled :) ${reset}\n"
		exit
	else
		printf "$red not installed so not removed${reset}\n"
	fi
}

printline() {
	printf "${blue}\n"
	echo " #------------------------------------------#"
}

usage() {
	printf "$red use ${yellow}bash TermuxAlpine.sh --uninstall\n"
	exit 1
}

# Start
clear
EXTRAARGS="default"
if [[ ! -z "$1" ]]
	then
	EXTRAARGS=$1
fi
if [[ $EXTRAARGS = "--uninstall" ]]
then
	cleanup
	exit

elif [ $# -ge 1 ]
then
	usage
else
printf "\n${yellow} You are going to install Alpine in termux ;) Cool\n Only 1mb Yes to continue\n\n"

checksysinfo
checkdeps
gettarfile
getsha
checkintegrity
extract
createloginfile

printf "$blue [*] Configuring Alpine For You ..."
cd; finalwork

printline
printf "\n${yellow} Now you can enjoy a very small (just 1 MB!) Linux environment in your Termux :)\n Don't forget to like my hard work for termux and many other things\n"
printline
printline
printf "\n${blue} [�] Email   :${yellow}    lkpandey950@gmail.com\n"
printf "$blue [�] Website :${yellow}    https://hax4us.com\n"
printf "$blue [�] YouTube :${yellow}    https://youtube.com/hax4us\n"
printline
printf "$red \n NOTE : $yellow use ${red}--uninstall${yellow} option for uninstall\n"
printline
printf "$reset"
fi
