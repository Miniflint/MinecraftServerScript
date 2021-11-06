#!/bin/bash
#variable time
NC='\033[0m' # No Color
green=`tput setaf 2`
RED='\033[0;31m'
cyan='\033[0;36m'
printf "\033c"

echo -e "${green}list of worlds : ${NC}"
for entry in "/opt"/mine*
do
	echo "${entry}" | cut -c 15-
done
echo -e "\n${green}Enter the name of the world to delete${NC}"
read World

dirName="/opt/minecraft${World}"
scriptName="/opt/scripts/${World}.sh"

check_if_ok () {
        not_ok="${NC}[${RED}NOT OK${NC}] : $2"
        if [[ $1 == 1 ]]
        then
                echo -e "${NC}[${green}OK${NC}] : $2"
        elif [[ $1 == 0 ]]
        then
                echo -e ${not_ok}
                exit
        else
                echo -e ${not_ok}
        fi
}

if [[ -d $dirName ]]
then
	rm -rf ${dirName}
	sleep 1
	if [[ ! -d $dirName ]]
	then
		check_if_ok 1 "Removing the world"
	else
		check_if_ok 0 "Removing the world"
	fi
fi

if [[ -f $scriptName ]]
then
	rm ${scriptName}
	sleep 1
	if [[ ! -f $scriptName ]]
	then
		check_if_ok 1 "Removing script"
	else
		check_if_ok 0 "Removing script"
	fi
fi
