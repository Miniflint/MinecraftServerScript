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
default_folder_path="/home/[CHANGE_ME]/servers_folder"
dir_path="${default_folder_path}/minecraft${dir_name}"
path_jar="${dir_path}/${name}"
if [[ $url == *"forge"* ]]
then
	startup="bash ${dir_path}/run.sh nogui "
else
	startup="java -Xms4G -Xmx4G -jar ${path_jar} nogui "
fi
script_path="${default_folder_path}/scripts"
dir_script=`pwd`

#install requirement. you may need to use another version of open-JDK
#you may also need multiple java version
#you can add a package by doing this : package+=("package_name_here")
#exemple -> package+=("openjdk-13-jdk")

package=("net-tools" "curl" "screen")
package+=("openjdk-17-jre-headless")

#fonction to print if it's OK or NOT OK
check_if_ok () {
	local waiting="${no_color}[${cyan}NOT OK${no_color}] : $2"
	local not_ok="${no_color}[${red}NOT OK${no_color}] : $2"
	local ok="${no_color}[${green}OK${no_color}] : $2"
	if [[ $1 == 1 ]]
	then
		echo -e ${ok}
	elif [[ $1 == 0 ]]
	then
		echo -e ${not_ok}
	elif [[ $1 == 2 ]]
	then
		echo -e ${not_ok}
		exit
	else
		echo -e ${waiting}
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

sleep 1
#check pre-requisite
for pkg in ${package[@]}
do
	sudo apt-get install -y "$pkg" > /dev/null
	if [[ `apt-cache search --names-only "$pkg"` ]]
	then
		check_if_ok 1 "installation of pre-requisite -> $pkg"
	else
		check_if_ok 0 "installation of pre-requisite -> $pkg"
		#try resintallation if fail on first try
		sudo apt-get install -y "$pkg" &> log.txt
		sleep 1
		if [[ `apt-cache search --names-only "$packages"` ]]
		then
			check_if_ok 1 "re-installation of pre-requisite -> $pkg"
		else
			check_if_ok 0 "re-installation of pre-requisite -> $pkg"
			read_file
		fi
	fi
done

sleep 1
#Check for the default_directory (/opt) (should exists by default. stand for "optional")
if [[ -d ${default_folder_path} ]]
then
	check_if_ok 1 "Checking ${default_folder_path}"
else
	check_if_ok 0 "Checking ${default_folder_path}"
	mkdir "${default_folder_path}"
	sleep 1
	if [[ -d ${default_folder_path} ]]
	then
		check_if_ok 1 "Creating ${default_folder_path}"
	else
		check_if_ok 2 "Creating ${default_folder_path}"
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

#writing the script
bin=$"#!/bin/bash\n\t"
echo -e "${bin} cd ${dir_path} && ${startup}" > "${script_path}/${dir_name}.sh" 
chmod +x ${script_path}/${dir_name}.sh
if [[ $url != *"forge"* ]]
then
	cp ${script_path}/${dir_name}.sh ${dir_path}/
fi
sleep 1
if [[ -f ${script_path}/${dir_name}.sh ]]
then
	check_if_ok 1 "Creation of the script"
else
	check_if_ok 0 "Creation of the script"
fi

#accepting eula terms
if [[ -f "${dir_path}/eula.txt" ]]
then
	sed -i 's/eula=false/eula=true/' ${dir_path}/eula.txt
else
	echo "eula=true" > ${dir_path}/eula.txt
fi
check_if_ok 1 "Accepting EULA terms"

#writing server.properties in server.properties
cp "$dir_script/server.properties/$game_mode.txt" "${dir_path}/server.properties" 
if [[ -s server.properties ]]
then
	check_if_ok 1 "Server.properties overwrite"
else
	check_if_ok 2 "Server.properties overwrite"
fi

if [[ $url == *"forge"* ]]
then
	cd ${dir_path}
	echo "Starting to unjar the file. it may take some time"
	java -jar ${dir_path}/${dir_name}.jar --installServer > /dev/null &
	PID=$!
	i=0
	echo -ne "Loading"
	while kill -0 $PID 2>/dev/null 
	do
		if [ $i -gt 10 ]
		then
			i=0
			echo -ne "\033[2K"
			echo -ne "\rLoading"
		else
			echo -ne "."
		fi
		((i++))
		sleep 1
	done
	check_if_ok 1 "Waiting the file"
fi

#create service
systemctl_var="""
[Unit]\n
Description=Minecraft Server ${dir_name}\n
After=network.target\n
\n
[Service]\n
User=root\n
Group=root\n
WorkingDirectory=${script_path}\n
ExecStart=/usr/bin/screen -dmS service_${dir_name} /bin/bash ${script_path}/${dir_name}.sh\n
ExecStop=/bin/bash -c 'screen -S service_${dir_name} -p 0 -X stuff \"stop\"'\n
Type=simple\n
RemainAfterExit=yes\n
Restart=on-failure\n
\n
[Install]\n
WantedBy=multi-user.target\n
"""
echo -e ${systemctl_var} > ${dir_path}/${dir_name}.service
if [[ -s ${dir_path}/${dir_name}.service ]]
then
	check_if_ok 1 "Service file creation"
else
	check_if_ok 2 "Service file creation"
fi

sleep 1
check_if_ok 1 "Having fun"
echo -e "${no_color}THANKS FOR DOWNLOADING\nTo start the server : cd ${script_path} + ./${dir_name}.sh\n"
echo -e "${no_color}To create the service (start server on reboot): sudo cp ${dir_path}/${dir_name}.service /etc/systemd/system/\n"
