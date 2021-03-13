#!/bin/bash

NC='\033[0m' # No Color
green=`tput setaf 2`
RED='\033[0;31m'
cyan='\033[0;36m'
printf "\033c"
now="$(date +'%d-%m')"

echo -e "${green}Enter the full path of the folder to backup, ex : ${NC}/opt/minecraftPaperMCServer"
read PathToBackup
[ ! -d "${PathToBackup}" ] && echo -e "" && echo -e "${RED}ERROR : Directory '${PathToBackup}' doesn't exist." && echo -e "${NC}" && exit
echo -e "${green}Enter the name of the backup, ex : ${NC}Backup-"
read Name
echo -e "${green}Enter the location of the backup folder, ex : ${NC}/home/ubuntu/Backup"
read DirPath
[ ! -d "${DirPath}" ] && echo -e "" && echo -e "${RED}ERROR : Directory '${DirPath}' doesn't exist." && echo -e "${NC}" && exit
echo -e "${cyan}"
tar -czvf "${DirPath}/${Name}${now}.tar.gz" "${PathToBackup}"
sleep 3
if [ -f "${DirPath}/${Name}${now}.tar.gz" ]
then
        echo -e "" && echo -e "${NC}back-uping the world : [${green}OK${NC}]"
else
         echo -e "" && echo -e "${NC}back-uping the world : [${RED}NOT OK${NC}]."
fi
