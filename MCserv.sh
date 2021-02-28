#!/bin/bash

#variable time
NC='\033[0m' # No Color
green=`tput setaf 2`
RED='\033[0;31m'
idkcolor '\033[36m'

echo -e "Enter The name of the server ex : ${green}PaperMC ${NC}/ ${RED}ForgeServer: ${NC}\n"
read -r -p DirName
echo -e "Now please enter the url of the file to download ex : ${idkcolor}https.../.../.../.../file.jar: ${NC}\n"
read -r -p Url
Name="${DirName}.jar"
DirPath="/opt/minecraft${DirName}"
PathJar="/opt/minecraft${DirName}/${Name}"
Startup="java -Xms1024M -Xmx2048M -jar ${PathJar} nogui"
printf "\033c"


set -eu -o pipefail # fail on error , debug all lines

sudo -n true
test $? -eq 0 || exit 1 "You should have sudo priveledge to run this script"

echo -e "${green}Installing the must-have pre-requisites${NC}${RED}"
while read -r p ; do sudo apt-get install -y $p ; done < <(cat << "EOF"
    net-tools
    openjdk-8-jdk
    curl
    screen
EOF
)
echo -e "${NC}Installation of pre-requisite : [${green}OK${NC}]"
sleep 2
printf "\033c"

echo -e "${green}Creating the folder for minecraft in /opt and installing ${DirName}${NC}"
mkdir ${DirPath}
cd ${DirPath}
echo -e "${NC}Folder Creation : [${green}OK${NC}]"

echo -e "\n${green}Installing ${DirName} for the server${NC}${RED}"
if [[ $Url == *"forge"* ]]; then
	curl -o ${Name} ${Url} --installServer
else
	curl -o ${Name} ${Url}
fi
echo -e "${NC}Installation of ${DirName} : [${green}OK${NC}]"

echo -e "\n\n${green}Un-jaring the file${NC}${RED}"
cd ${DirPath}
java -jar ${Name} #java -jar PaperMC.jar
echo -e "${NC}Un-jaring the file : [${green}OK${NC}]"

echo -e "\n\n${green}Starting the file server${NC}${RED}"
cd ${DirPath} && ${Startup}
echo -e "${NC}Starting the Server File : [${green}OK${NC}]"

echo -e "\n\n${green}Accepting the EULA TERM${NC}${RED}"
sed -i 's/eula=false/eula=true/' eula.txt
echo -e "${NC}Changing file Configuration : [${green}OK${NC}]"

echo -e "\n\n${green}Writing in server.properties${NC}"
ServerProperties=$"#Minecraft server properties\n#(last boot timestamp)\nenable-jmx-monitoring=false\nrcon.port=25575\nlevel-seed=\gamemode=survival\nenable-command-block=false\nenable-query=false\ngenerator-settings=\nlevel-name=world\nquery.port=25565\npvp=true\ngenerate-structures=true\ndifficulty=easy\nnetwork-compression-threshold=256\nmax-tick-time=60000\nmax-players=15\nuse-native-transport=true\nonline-mode=true\nenable-status=true\nallow-flight=false\nbroadcast-rcon-to-ops=true\nview-distance=10\nmax-build-height=256\nserver-ip=\nallow-nether=true\nserver-port=25565\nenable-rcon=false\nsync-chunk-writes=true\nop-permission-level=4\nprevent-proxy-connections=false\nresource-pack=\nentity-broadcast-range-percentage=100\nrcon.password=\nplayer-idle-timeout=0\nforce-gamemode=false\nrate-limit=0\nhardcore=false\nwhite-list=true\nbroadcast-console-to-ops=true\nspawn-npcs=true\nspawn-animals=true\nsnooper-enabled=true\nfunction-permission-level=2\nlevel-type=default\nspawn-monsters=true\nenforce-whitelist=false\nresource-pack-sha1=\nspawn-protection=16\nmax-world-size=29999984\nmotd=SERVER"
echo ${ServerProperties} > server.properties
echo -e "${NC}Server.properties overwrite: [${green}OK${NC}]"

echo -e "$\n{green}Creating the script folder and start the minecraft server${NC}"
cd /opt && mkdir scripts
cd scripts
bin=$"#!/bin/bash\n\t"
echo -e "${bin} cd ${DirPath} && ${Startup}" > minecraft.sh
chmod +x minecraft.sh
echo -e "${NC}Creation of the script: [${green}OK${NC}]"
sleep 3
printf "\033c"
read -n1 -r -p "Install the script at the boot [Y/n]: " input
 
case $input in
    [yY][eE][sS]|[yY])
 echo -e "\n\n${green}Installing the script${NC}"
 echo "screen -dm -S minecraft /opt/scripts/minecraft.sh" > /etc/rc.local
 chmod +x /etc/rc.local
 echo -e "${NC}Server on Startup: [${green}OK${NC}]"
;;
    [nN][oO]|[nN])
 echo "\n\nThanks for downloading :)"
       ;;
    *)
 echo "Invalid input"
 exit 1
 ;;
esac
echo -e "\n${green}Configuring the start of the server"
screen -S ${DirName} && cd ${DirPath} && ${Startup}
echo -e "${NC}Configuration at the start of the server : [${green}OK${NC}]"
sleep 3

