#!/bin/bash
#variable time
no_color='\033[0m' # No Color
green=`tput setaf 2`
red='\033[0;31m'
cyan='\033[0;36m'

#clear screen
printf "\033c"

#############################################################################################################################
############################## BY USING THIS SCRIPT YOU ACCEPT MOJANG'S EULA ################################################
#############################################################################################################################

#Get input on :
#1. Folder name
#2. url
#3. Game mode
echo -e "${green}Enter The name of your folder  ex : ${cyan}Vanilla ${no_color}/ PaperMC / ${red}ForgeServer: ${no_color}"
read dir_name
echo -e "${green}Now please enter the url of the file to download ex : ${no_color}https.../.../.../.../file.jar: ${no_color}"
read url
echo -e "${green}Enter the gamemode -> ex : ${no_color}survival ${red}/ ${no_color}hardcore ${red}/ ${no_color}creative${no_color}"
read game_mode

#Declare variables
name="${dir_name}.jar"
dir_path="/opt/minecraft${dir_name}"
path_jar="${dir_path}/${name}"
startup="java -Xms4G -Xmx5G -jar ${path_jar} nogui "
script_path="/opt/scripts"


#install requirement. you may need to use another version of open-JDK
#you may also need multiple java version
#you can add a package by doing this : package+=("package_name_here")
#exemple -> package+=("openjdk-13-jdk")

package=("net-tools" "curl" "screen")
package+=("openjdk-16-jdk")
#test if it's on admin
sudo -n true
test $? -eq 0 || exit 1 "You should have sudo priveledge to run this script"

#fonction to print if it's OK or NOT OK
check_if_ok () {
	local not_ok="${no_color}[${red}NOT OK${no_color}] : $2"
	local ok="${no_color}[${green}OK${no_color}] : $2"
	if [[ $1 == 1 ]]
	then
		echo -e ${ok}
	elif [[ $1 == 0 ]]
	then
		echo -e ${not_ok}
	else
		echo -e ${not_ok}
		exit
	fi
}

read_file () {
	local input="log.txt"
	echo -e "\n${red}Reason of the fail : \n${no_color}"
	while IFS= read -r line
	do
		echo "$line"
	done < "$input"
	echo ""
	rm "log.txt"
	exit
}

test $? -eq 0 || check_if_ok 2 "Start with sudo privileges"

if [[ -d $dir_path ]]
then
	check_if_ok 2 "This folder already exists"
fi


for packages in "${packages[@]}"
do
	sudo apt-get install -y "$packages" &> /dev/null
done
sleep 1

#check pre-requisite
for packages in ${package[@]}
do
	if [[ `apt-cache search --names-only "$packages"` ]]
	then
		check_if_ok 1 "installation of pre-requisite -> $packages"
	else
		check_if_ok 0 "installation of pre-requisite -> $packages"
		#try resintallation if fail on first try
		sudo apt-get install -y "$packages" &> log.txt
		sleep 1
		if [[ `apt-cache search --names-only "$packages"` ]]
		then
			check_if_ok 1 "re-installation of pre-requisite -> $packages"
		else
			check_if_ok 0 "re-installation of pre-requisite -> $packages"
			read_file
		fi
	fi
done

sleep 1
#Check for the /opt directory (should exists by default. stand for "optional")
if [[ -d /opt ]]
then
	check_if_ok 1 "Checking /opt"
else
	check_if_ok 0 "Checking /opt"
	mkdir "/opt"
	sleep 1
	if [[ -d /opt ]]
	then
		check_if_ok 1 "Checking /opt"
	else
		check_if_ok 2 "Checking /opt"
	fi
fi

#make the directory that will have all the files
mkdir ${dir_path}
sleep 1
if [[ -d ${dir_path} ]]
then
	check_if_ok 1 "Folder Creation"
else
	check_if_ok 2 "Folder Creation"
fi

#check if the script path already exists
if [[ -d ${script_path} ]]
then
        check_if_ok 1 "'Scripts' folder"
else
        check_if_ok 0 "'Scripts' folder"
	#on fail, try to do it again
        mkdir ${script_path}
        sleep 1
        if [[ -d ${script_path} ]]
        then
                check_if_ok 1 "Creation of the 'scripts' folder"
        else
		#exit on fail number 2
                check_if_ok 2 "Creation of the 'scripts' folder"
        fi
fi

#check for the server.properties/gamemode file
bin=$"#!/bin/bash\n\t"
if [[ -f "server.properties/$game_mode.txt" ]]
then
        check_if_ok 1 "Checking file"
else
        check_if_ok 2 "Checking file"
fi

#downloading url
curl -o ${path_jar} ${url} --silent
if [[ -f ${path_jar} ]]
then
	check_if_ok 1 "Download URL"
else
	check_if_ok 2 "Download URL"
	curl -o ${path_jar} ${url} >> log.txt
	read_file
fi

############### IF URL IS FORGE STARTING IS DIFFERENT #########
############### I DON'T KNOW IF IT STILL WORKS ################

if [[ $url == *"forge"* ]]
then
	java -jar ${path_jar} --installServer &> log.txt
else
	java -jar ${path_jar} &> log.txt
fi
if [ $? -eq 0 ]
then
	check_if_ok 1 "Un-jaring the file"
else
	check_if_ok 0 "Un-Jaring the file"
	read_file
fi

${startup} &> log.txt
#Checking server.properties file
if [[ -f "${dir_path}/server.properties" ]]
then
	check_if_ok 1 "Starting the server"
else
	check_if_ok 0 "Starting the server"
	read_file
fi

#accepting eula terms
sed -i 's/eula=false/eula=true/' eula.txt
if [ $? -ne 0 ]
then
	check_if_ok 1 "Accepting EULA terms"
else
	check_if_ok 2 "Accepting EULA terms"
fi


#writing server.properties in server.properties
rm "${dir_path}/server.properties"
cp "server.properties/$game_mode.txt" "${dir_path}/server.properties" 
if [[ -s server.properties ]]
then
	check_if_ok 1 "Server.properties overwrite"
else
	check_if_ok 2 "Server.properties overwrite"
fi

#writing the script
bin=$"#!/bin/bash\n\t"
echo -e "${bin} cd ${dir_path} && ${startup}" > "${script_path}/${dir_name}.sh"
chmod +x ${script_path}/${dir_name}.sh
sleep 1

if [[ -f ${script_path}/${dir_name}.sh ]]
then
	check_if_ok 1 "Creation of the script"
else
	check_if_ok 0 "Creation of the script"
	echo -e "${bin} cd ${dir_path} && ${startup}" > "${script_path}/${dir_name}.sh"
	if [[ -f ${script_path}/${dir_name}.sh ]]
	then
        	check_if_ok 1 "Creation of the script"
	else
        	check_if_ok 2 "Creation of the script"
	fi
fi

sleep 1
check_if_ok 1 "Having fun"
echo -e "${no_color}THANKS FOR DOWNLOADING\nTo start the server : cd ${script_path} + ./${dir_name}.sh"
