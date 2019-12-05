#!/bin/bash

#if [  $1 ] ;then
#    user=$1
#    echo "user name is $1"
#else
#    user="fugli"
#    echo "default user name: fugli used"
#fi

user="fugli"
folder=log_$(date +%s)
mkdir $folder

server=${user}@hzling01.china.nsn-net.net
workspace=/var/fpwork/${user}/gnb/uplane/build/src/ttiTrace/decoder/csvOutput

echo "server: $server "
echo "......................>"
echo "workspace: $workspace "
echo "<......................"
read -p "OK ? Press any key to continue "

cp 5GTtiTrace.*.tar.gz ParseTtiTrace.sh $folder

##copy all 5GTtiTrace.*.tar.gz files and  parese script to server 
scp -r $folder ${server}:${workspace}

##login server and run parese script
ssh ${server} << remotessh    
cd ${workspace}/$folder
chmod 777 *
source ParseTtiTrace.sh
remotessh

echo "parese done"

scp ${server}:${workspace}/$folder/dl.csv .
scp ${server}:${workspace}/$folder/ul.csv .  

ssh ${server} "cd ${workspace}; rm -rf $folder"


rm -rf $folder

echo "done !"
