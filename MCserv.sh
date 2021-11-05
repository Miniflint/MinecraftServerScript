#!/bin/bash
#variable time
NC='\033[0m' # No Color
green=`tput setaf 2`
RED='\033[0;31m'
cyan='\033[0;36m'
printf "\033c"

echo -e "${green}Enter The name of your folder  ex : ${NC}PaperMC ${NC}/ ${RED}ForgeServer: ${NC}"
read DirName
echo -e "${green}Now please enter the url of the file to download ex : ${NC}https.../.../.../.../file.jar: ${NC}"
read Url
echo -e "${green}Enter the gamemode -> ex : ${NC}survival ${RED}/ ${NC}hardcore ${RED}/ ${NC}creative${NC}"
read Gamemode

Name="${DirName}.jar"
DirPath="/opt/minecraft${DirName}"
PathJar="/opt/minecraft${DirName}/${Name}"
Startup="java -Xms4G -Xmx5G -jar ${PathJar} nogui "


set -eu -o pipefail # fail on error , debug all lines

sudo -n true
test $? -eq 0 || exit 1 "You should have sudo priveledge to run this script"

while read -r p ; do sudo apt-get install -y $p &> /dev/null; done < <(cat << "EOF"
    net-tools
    openjdk-16-jdk
    curl
    screen
EOF
)
echo -e "${NC}Installation of pre-requisite : [${green}OK${NC}]"
sleep 2

mkdir ${DirPath}
sleep 2
if [[ -d ${DirPath} ]]
then
    echo -e "${NC}Folder Creation : [${green}OK${NC}]"
else
    echo -e "${NC}Folder Creation : [${RED}NOT OK${NC}]"
    exit
fi

curl -o ${PathJar} ${Url} --silent
[ ! -f ${PathJar} ] && echo -e "${NC}Installation of the server : [${RED}NOT OK${NC}]" && exit|| echo -e "${NC}Installation of the server : [${green}OK${NC}]"

cd ${DirPath}
if [[ $Url == *"forge"* ]]
then
	java -jar ${PathJar} --installServer &> /dev/null
else
	java -jar ${PathJar} &> /dev/null 
fi
echo -e "${NC}Un-jaring the file : [${green}OK${NC}]"

if [[ $Url == *"forge"* ]]
then
	var=$(/bin/find ${DirPath} -maxdepth 1 -name "forge-1.*.jar")
	echo -e "${RED}${var}\n${DirPath}"
	cd ${DirPath} && java  -Xms1024M -Xmx2000M -jar ${var} nogui #    cd /opt/minecraft && java -Xms1024M -Xmx2000M -jar /opt/minecraft/forge-1.12.2-14.23.5.2854.jar nogui 
else
	${Startup} &> /dev/null
fi
[ ! -f "${DirPath}/server.properties" ] echo -e "${NC}Starting the Server File : [${RED}NOT OK${NC}]" && exit || echo -e "${NC}Starting the Server File : [${green}OK${NC}]"

sed -i 's/eula=false/eula=true/' eula.txt
echo -e "${NC}Accepting EULA TERM : [${green}OK${NC}]"

ServerProperties="cat server.properties/${Gamemode}.txt"
echo ${ServerProperties} > server.properties
[ ! -s server.properties ] && echo -e "${NC}Server.properties overwrite: [${RED}NOT OK${NC}]" && exit || echo -e "${NC}Server.properties overwrite: [${green}OK${NC}]"

scriptPath="/opt/scripts"
[ ! -d ${scriptPath} ] && echo -e "${green}Directory 'script' don't exist : creating one" && cd /opt mkdir scripts && sleep 3
	[ ! -d ${scriptPath} ] && echo -e "${NC}Creation of the directory script: [${RED}NOT OK${NC}]" && exit || echo -e "${NC}Creation of the directory script: [${green}OK${NC}]"

bin=$"#!/bin/bash\n\t"
echo -e "${bin} cd ${DirPath} && ${Startup}" > "${scriptPath}/${DirName}.sh"
chmod +x ${scriptPath}/${DirName}.sh
sleep 2
[ ! -f ${scriptPath}/${DirName}.sh ] && echo -e "${NC}Creation of the script: [${RED}NOT OK${NC}]" && exit || echo -e "${NC}Creation of the script: [${green}OK${NC}]"
sleep 2
cd ${scriptPath}
