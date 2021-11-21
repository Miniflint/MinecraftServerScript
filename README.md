# MinecraftServerScript
### What the script do : [Click here](https://github.com/Miniflint/MinecraftServerScript/blob/main/README.md#what-the-script-do)
Automatically install and configue a minecraft server
Worked on Raspberry Pi 4 B+ using Ubuntu Server 20.04 Using Ssh via PuTTY and tested with forge 1.16.4, PaperMC 1.16.4 and 1.17.1, and Pure vanilla 1.16.4

TO PLAY ON THE SERVER LOCALLY, IT'S THE IP OF YOUR SERVER : ifconfig -> (192.168.x.x generally)

IF YOU WANT TO PLAY WITH FRIENDS, OPEN THE PORT 25565 ON YOUR ROUTER AND ALLOW TRAFIC FROM PORT 25565

###                               **ONLY WORKS ON LINUX**
## Usage
Installation of the script :

```git clone https://github.com/Miniflint/MinecraftServerScript```

go in the directory :

```cd MinecraftServerScript```

executing the script :

`./MCserv.sh`

if you can't execute the script :
make the script executable :

`chmod +x MCserv.sh`

If you want to change the RAM usage of your server :

`Nano MCserv.sh`
or
`Vim MCserv.sh`

And change the value of "-Xms[VALUE(1024=1G ram)] and -Xmx[VALUE(2048=2G ram)]

`Startup="java -Xms1024M -Xmx2048M -jar ${PathJar} nogui"`

Xms is the amount of ram the server will start with and Xmx is the maximum

## What the script do
What the script do is :
  1. Ask you to put a name for the directory and the name of the server
  2. Ask you for the jar file URL, here is a list for you
     - [forge](https://maven.minecraftforge.net/net/minecraftforge/forge/1.17.1-37.0.108/forge-1.17.1-37.0.108-installer.jar) Version 1.17.1 (Care when you input the forge version, it redirect to an adfocus page, you have to cut the first part [https://adfoc.us/serve/sitelinks/?id=271228&url=] and only keep the second part : [https://maven.minecraftforge.net/net/minecraftforge/forge/1.17.1-37.0.108/forge-1.17.1-37.0.108-installer.jar])
     - [PaperMC](https://papermc.io/api/v2/projects/paper/versions/1.17.1/builds/378/downloads/paper-1.17.1-378.jar) Version 1.17.1 build #378
     - [Pure vanilla](https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar) Version 1.17.1
  3. Ask you which game mode you want
     - Creative
     - Survival
     - Hardcore
  4. Check requirements
     - if a requirement is missing, install it
  5. Create a folder in minecraft+the_name_you_gave in /opt
  6. Check if the scripts folder already exists
     - if not, create it in /opt/scripts
  7. Checking if the file in server.properties/(Gamemode_you_Chose).txt exists
     - if not, stop the script
  8. Download the jar file that you gave in this folder
  9. Run the file
  10. Starting the file to get an error (which leads into accepting the EULA terms)
  11. Accept the EULA TERM
  12. Write server.properties (/opt/minecraft+TheNameYouChoose)/server.properties
  13. Write a script to start the server with only 1 command in /opt/scripts and make it executable
