# MinecraftServerScript
Automatically install and configue a minecraft server
Worked on Raspberry Pi 3 B+ using Ubuntu Server 20.04 Using Ssh via PuTTY and tested with forge 1.16.4
# TO PLAY ON THE SERVER LOCALLY, IT'S THE IP OF YOUR SERVER : ifconfig -> (192.168.x.x generally)
# IF YOU WANT TO PLAY WITH FRIENDS, OPEN THE PORT 25565 ON YOUR ROUTER AND ALLOW TRAFIC FROM PORT 25565

#                               #### ONLY WORKS ON LINUX ####

Installation of the script :
```
git clone https://github.com/Miniflint/MinecraftServerScript
```

make the script executable :
```
chmod +x MCserv.sh
```

executing the script :
```
./MCserv.sh/
```

If you want to change the RAM usage of your server : 
```
Nano MCserv.sh
```

And change the value of "-Xms[VALUE(1024=1G ram)] and -Xmx[VALUE(2048=2G ram)]
```
Startup="java -Xms1024M -Xmx2048M -jar ${PathJar} nogui"
```
Xms is the amount of ram the server will start with and Xmx is the maximum

What the script do is :
  1. Ask you to put a name for the directory and the name of the server
  2. Ask you for the jar file URL, here is a list for you :
    2a. https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/503/downloads/paper-1.16.5-503.jar
    2b. https://files.minecraftforge.net/maven/net/minecraftforge/forge/1.16.4-35.1.37/forge-1.16.4-35.1.37-installer.jar
       2ba. (Be careful when you get the link, it show and adfocus before  and it doesn't work. You have to delete everything before url=(including url=)
    2d. https://cdn.getbukkit.org/spigot/spigot-1.16.5.jar
#   2e. NOTE : THE SERVER VERSION IS 1.16.5 FOR SPIGOT AND PAPERMC - FORGE IS IN 1.16.4

  3. install these requirements
    3a. net-tools
    3b. openjdk-8-jdk
    3c. curl
    3d screen
  4. create a folder in /opt/minecraft+the name you chose
  5. download the jar in this folder
  6. run the jar file
  7. accept the EULA TERM
  8. write server.properties (/opt/minecraft+TheNameYouChoose)/server.properties
  9. write a script to start the server with only 1 command in /opt/scripts and make it executable
  10. Ask you if you want to start it at every boot
    10a. if yes : install it at /etc/rc.local
    10b. if no  : skip this
  11. Start the server
