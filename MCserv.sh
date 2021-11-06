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
scriptPath="/opt/scripts"

set -eu -o pipefail # fail on error , debug all lines

sudo -n true
test $? -eq 0 || exit 1 "You should have sudo priveledge to run this script"

check_if_ok () {
	if [[ $1 == 1 ]]
	then
		echo -e "${NC}$2 : [${green}OK${NC}]"
	elif [[ $1 == 0 ]]
		echo -e "${NC}$2 : [${RED}NOT OK${NC}]"
		exit
	else
		echo -e "${NC}$2 : [${RED}NOT OK${NC}]"
	fi

}

while read -r p ; do sudo apt-get install -y $p &> /dev/null; done < <(cat << "EOF"
    net-tools
    openjdk-16-jdk
    curl
    screen
EOF
)
check_if_ok 1 "installation of pre-requisite"
sleep 2

mkdir ${DirPath}
sleep 2
if [[ -d ${DirPath} ]]
then
	check_if_ok 1 "Folder Creation"
else
	check_if_ok 0 "Folder Creation"
fi

if [[ -d /opt ]]
then
	check_if_ok 1 "Checking /opt"
else
	check_if_ok 2 "Checking /opt"
	mkdir "/opt"
fi

if [[ -d ${scriptPath} ]]
then
        check_if_ok 1 "'Scripts' folder"
else
        check_if_ok 2 "'Scripts' folder"
        mkdir ${scriptPath}
        sleep 3
        if [[ -d ${scriptPath} ]]
        then
                check_if_ok 1 "Creation of the 'scripts' folder"
        else
                check_if_ok 0 "Creation of the 'scripts' folder"
        fi
fi
bin=$"#!/bin/bash\n\t"
if [[ -f "server.properties/$Gamemode.txt" ]]
then
        ServerProperties=$(cat server.properties/${Gamemode}.txt)
        check_if_ok 1 "Checking file"
else
        check_if_ok 0 "Checking file"
fi

curl -o ${PathJar} ${Url} --silent
if [[ -f ${PathJar} ]]
then
	check_if_ok 1 "Download URL"
else
	check_if_ok 0 "Download URL"
fi

cd ${DirPath}
if [[ $Url == *"forge"* ]]
then
	java -jar ${PathJar} --installServer &> /dev/null
else
	java -jar ${PathJar} &> /dev/null 
fi
check_if_ok 1 "Un-jaring the file"

if [[ $Url == *"forge"* ]]
then
	var=$(/bin/find ${DirPath} -maxdepth 1 -name "forge-1.*.jar")
	echo -e "${RED}${var}\n${DirPath}"
	cd ${DirPath} && java  -Xms1024M -Xmx2000M -jar ${var} nogui #    cd /opt/minecraft && java -Xms1024M -Xmx2000M -jar /opt/minecraft/forge-1.12.2-14.23.5.2854.jar nogui 
else
	${Startup} &> /dev/null
fi
if [[ -f "${DirPath}/server.properties" ]]
then
	check_if_ok 1 "Starting the Server File"
else
	check_if_ok 0 "Starting the Server File"
fi

sed -i 's/eula=false/eula=true/' eula.txt
check_if_ok 1 "Acceptiing EULA terms"

echo ${ServerProperties} > server.properties
if [[ -s server.properties ]]
then
	check_if_ok 1 "Server.properties overwrite"
else
	check_if_ok 0 "Server.properties overwrite"
fi

bin=$"#!/bin/bash\n\t"
echo -e "${bin} cd ${DirPath} && ${Startup}" > "${scriptPath}/${DirName}.sh"
chmod +x ${scriptPath}/${DirName}.sh
sleep 2

if [[ -f ${scriptPath}/${DirName}.sh ]]
then
	check_if_ok 1 "Creation of the script"
else
	check_if_ok 2 "Creation of the script"
	echo -e "${bin} cd ${DirPath} && ${Startup}" > "${scriptPath}/${DirName}.sh"
	if [[ -f ${scriptPath}/${DirName}.sh ]]
	then
        	check_if_ok 1 "Creation of the script"
	else
        	check_if_ok 2 "Creation of the script"
		echo "can't create the script"
		exit
	fi
fi

sleep 2
cd ${scriptPath}
echo -e "${cyan}THANKS FOR DOWNLOADING${NC}"
check_if_ok 1 "Having fun"
