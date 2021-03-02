#!/bin/bash

NC='\033[0m' # No Color
green=`tput setaf 2`
RED='\033[0;31m'
cyan='\033[0;36m'
printf "\033c"
now="$(date +'%d-%m-%Y')"

echo -e "${green}Enter the full path of the folder to backup, ex : ${NC}/opt/MinecraftPaperMC"
read PathToBackup
echo -e "${green}Enter the name of the backup${NC}"
read Name
echo -e "${green}Enter the location of the backup folder${NC}"
read DirPath
echo -e "${cyan}"
tar czf "${DirPath}/${Name}${now}.tar.gz"  ${PathToBackup}
echo -e "${NC}back-uping the world : [${green}OK${NC}]"
