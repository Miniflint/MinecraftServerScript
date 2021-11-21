#!/bin/bash
#variable time
NC='\033[0m' # No Color
green=`tput setaf 2`
RED='\033[0;31m'
cyan='\033[0;36m'

#clear screen
printf "\033c"

#############################################################################################################################
############################## BY USING THIS SCRIPT YOU ACCEPT MOJANG'S EULA ################################################
#############################################################################################################################

#Get input on :
#1. Folder name
#2. Url
#3. Game mode
echo -e "${green}Enter The name of your folder  ex : ${NC}PaperMC ${NC}/ ${RED}ForgeServer: ${NC}"
read DirName
echo -e "${green}Now please enter the url of the file to download ex : ${NC}https.../.../.../.../file.jar: ${NC}"
read Url
echo -e "${green}Enter the gamemode -> ex : ${NC}survival ${RED}/ ${NC}hardcore ${RED}/ ${NC}creative${NC}"
read Gamemode

#Declare variables
Name="${DirName}.jar"
DirPath="/opt/minecraft${DirName}"
PathJar="/opt/minecraft${DirName}/${Name}"
Startup="java -Xms4G -Xmx5G -jar ${PathJar} nogui "
scriptPath="/opt/scripts"

set -eu -o pipefail # fail on error , debug all lines

#test if it's on admin
sudo -n true
test $? -eq 0 || exit 1 "You should have sudo priveledge to run this script"

#fonction to print if it's OK or NOT OK
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

if [[ -d $DirPath ]]
then
	check_if_ok 0 "This folder already exists"
fi
#install requirement. you may need to use another version of open-JDK
#you may also need multiple java version
#you can add a package by doing this : package+=("package_name_here")
#exemple -> package+=("openjdk-13-jdk")
############## KEEP IN MIND #####################################################
############## THESE ARE THE MINIMAL REQUIREMENT ################################
############## NET TOOLS CAN BE DELETED FROM REQUIREMENT, BUT PROBLEMS MAY COME #
############## CURL IS ESSENTIAL ALONG WITH SCREEN ##############################
############## THE JAVA VERSION CAN BE MODIFIED #################################
package=("net-tools" "curl" "screen")
#java version
package+=("openjdk-16-jdk")

for packages in "${packages[@]}"; do
  sudo apt-get install -y "$packages" &> /dev/null
done

sleep 1
#check pre-requisite
for packages in ${package[@]}
do
	if [[ `apt-cache search --names-only "$packages"` ]]
	then
		check_if_ok 1 "installation of pre-requisite : $packages"
	else
		check_if_ok 2 "installation of pre-requisite : $packages"
		#try resintallation if fail on first try
		sudo apt-get install -y "$packages" &> /dev/null
		sleep 1
		if [[ `apt-cache search --names-only "$packages"` ]]
		then
			check_if_ok 1 "installation of pre-requisite : $packages"
		else
			#exit if fail the second time
			check_if_ok 0 "installation of pre-requisite : $packages"
		fi
	fi
done

sleep 2

#Check for the /opt directory (should exists by default. stand for "optional")
if [[ -d /opt ]]
then
	check_if_ok 1 "Checking /opt"
else
	check_if_ok 2 "Checking /opt"
	mkdir "/opt"
fi

#make the directory that will have all the files
mkdir ${DirPath}
sleep 2
if [[ -d ${DirPath} ]]
then
	check_if_ok 1 "Folder Creation"
else
	check_if_ok 0 "Folder Creation"
fi

#check if the script path already exists
if [[ -d ${scriptPath} ]]
then
        check_if_ok 1 "'Scripts' folder"
else
        check_if_ok 2 "'Scripts' folder"
	#on fail, try to do it again
        mkdir ${scriptPath}
        sleep 3
        if [[ -d ${scriptPath} ]]
        then
                check_if_ok 1 "Creation of the 'scripts' folder"
        else
		#exit on fail number 2
                check_if_ok 0 "Creation of the 'scripts' folder"
        fi
fi

#check for the server.properties/gamemode file
bin=$"#!/bin/bash\n\t"
if [[ -f "server.properties/$Gamemode.txt" ]]
then
	ServerProperties=$(cat server.properties/${Gamemode}.txt)
        check_if_ok 1 "Checking file"
else
        check_if_ok 0 "Checking file"
fi

#downloading url
curl -o ${PathJar} ${Url} --silent
if [[ -f ${PathJar} ]]
then
	check_if_ok 1 "Download URL"
else
	check_if_ok 0 "Download URL"
fi


############### IF URL IS FORGE STARTING IS DIFFERENT #########
############### I DON'T KNOW IF IT STILL WORKS ################
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

#Checking server.properties file
if [[ -f "${DirPath}/server.properties" ]]
then
	check_if_ok 1 "Starting the Server File"
else
	check_if_ok 0 "Starting the Server File"
fi

#accepting eula terms
sed -i 's/eula=false/eula=true/' eula.txt
check_if_ok 1 "Acceptiing EULA terms"


#writing server.properties in server.properties
echo "${ServerProperties}" > server.properties
if [[ -s server.properties ]]
then
	check_if_ok 1 "Server.properties overwrite"
else
	check_if_ok 0 "Server.properties overwrite"
fi

#writing the script
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
check_if_ok 1 "Having fun"
echo -e "${cyan}THANKS FOR DOWNLOADING${NC}"
