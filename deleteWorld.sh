#!/bin/bash
#variable time
NC='\033[0m' # No Color
green=`tput setaf 2`
RED='\033[0;31m'
cyan='\033[0;36m'

for entry in "/opt"/mine*
do
	echo "${entry}" | cut -c 15-
done
echo -e "${green}Enter the name of the world to delete${NC}"
read World

dirName="/opt/minecraft${World}"
scriptName="/opt/scripts/${World}.sh"

if [[ -d $dirName ]]
then
	rm -rf ${dirName}
	sleep 1
	if [[ ! -d $dirName ]]
	then
		echo -e "${NC}Removing the world : [${green}OK${NC}]"
	else
		echo -e "${NC}Removing the world : [${RED}NOT OK${NC}]"
	fi
fi

if [[ -f $scriptName ]]
then
	rm ${scriptName}
	sleep 1
	if [[ ! -f $scriptName ]]
	then
		echo -e "${NC}Removing script : [${green}OK${NC}]"
	else
		echo -e "${NC}Removing script : [${RED}NOT OK${NC}]"
	fi
fi
