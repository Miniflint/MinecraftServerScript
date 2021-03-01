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
Name="${DirName}.jar"
DirPath="/opt/minecraft${DirName}"
PathJar="/opt/minecraft${DirName}/${Name}"
Startup="java -Xms1024M -Xmx2000M -jar ${PathJar} nogui "


set -eu -o pipefail # fail on error , debug all lines

sudo -n true
test $? -eq 0 || exit 1 "You should have sudo priveledge to run this script"

echo -e "\n${green}Installing the must-have pre-requisites${NC}${cyan}"
while read -r p ; do sudo apt-get install -y $p ; done < <(cat << "EOF"
    net-tools
    default-jre-headless
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

echo -e "\n${green}Installing ${DirName} for the server${NC}${cyan}"
curl -o ${Name} ${Url}
echo -e "${NC}Installation of ${DirName} : [${green}OK${NC}]"

echo -e "\n\n${green}Un-jaring on ${Name}${NC}${cyan}"
cd ${DirPath}
if [[ $Url == *"forge"* ]]; then
	java -jar ${Name} --installServer
else
	java -jar ${Name}
fi
echo -e "${NC}Un-jaring the file : [${green}OK${NC}]"

echo -e "\n\n${green}Starting the file server ${Startup}${NC}${cyan}"
if [[ $Url == *"forge"* ]]; then
	var=$(/bin/find ${DirPath} -maxdepth 1 -name "forge-1.*.jar")
	echo -e "${RED}${var}\n${DirPath}"
	cd ${DirPath} && java  -Xms1024M -Xmx2000M -jar ${var} nogui #    cd /opt/minecraft && java -Xms1024M -Xmx2000M -jar /opt/minecraft/forge-1.12.2-14.23.5.2854.jar nogui 
else
	cd ${DirPath} && ${Startup}
fi
echo -e "${NC}Starting the Server File : [${green}OK${NC}]"


echo -e "\n\n${green}Accepting the EULA TERM${NC}${cyan}"
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
read -n1 -r -p "Install the script at the boot [Y/n]: ${cyan}" input
 
case $input in
    [yY][eE][sS]|[yY])
 echo -e "\n\nInstalling the script${NC}"
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
