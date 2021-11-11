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
go in the directory :
```
cd MinecraftServerScript
```

make the script executable :
```
chmod +x MCserv.sh
```

executing the script :
```
./MCserv.sh
```

If you want to change the RAM usage of your server : 
```
Nano MCserv.sh
```
or
```
Vim MCserv.sh
```
And change the value of "-Xms[VALUE(1024=1G ram)] and -Xmx[VALUE(2048=2G ram)]
```
Startup="java -Xms1024M -Xmx2048M -jar ${PathJar} nogui"
```
Xms is the amount of ram the server will start with and Xmx is the maximum

##    What the script do
What the script do is :
  1. Ask you to put a name for the directory and the name of the server
  2. Ask you for the jar file URL, here is a list for you
  - test
  4. install requirements
  5. create a folder in /opt/minecraft+the name you chose
  6. download the jar in this folder
  7. run the jar file
  8. accept the EULA TERM
  9. write server.properties (/opt/minecraft+TheNameYouChoose)/server.properties
  10. write a script to start the server with only 1 command in /opt/scripts and make it executable
