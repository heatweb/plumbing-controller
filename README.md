# plumbing-controller
Open Source Plumbing Controller for achieving net zero.

See https://hwwiki.ddns.net/


## Standard Installation for Raspberry Pi

    bash <(curl -sL https://raw.githubusercontent.com/heatweb/plumbing-controller/main/scripts/start.sh)
    
Followed by:

    heatweb

## Docker Setup

    bash <(curl -sL https://raw.githubusercontent.com/heatweb/plumbing-controller/main/scripts/docker-setup.sh)
 
 ## Node-RED Installer
 
    sudo docker run -d -it -p 5099:1880 --net mqtt -v /boot/heatweb/:/boot/heatweb/ -v /home/pi/plumbing-controller/:/home/pi/plumbing-controller/ --add-host=host.docker.internal:host-gateway --privileged --name noderedsetup heatweb/noderedsetup:latest

