#!/bin/bash


# whiptail --title "Heatweb Plumbing Controller Setup" --msgbox "/\/\/\/\    Open-Source Plumbing Controller\n\ \ \ \/    Richard Hanson-Graville, Heatweb\n \/\/\/     31/12/2022\n\n            Apache 2.0 License" 15 78




# Read Password

CHECK64=$(uname -m)

#password=$(whiptail --passwordbox "Enter admin password" 8 60 3>&1 1>&2 2>&3)
#  if [[ -z "${password// }" ]]; then
#      printf "No password given - aborting\r\n"; exit
#  fi

if [ "/home/pi/plumbing-controller" ]; then
    echo "plumbing-controller installed. Updating."
    cd /home/pi/plumbing-controller
    git pull
else
    cd /home/pi
    git clone https://github.com/heatweb/plumbing-controller.git
fi

sudo apt-get -y update
sudo apt-get -y upgrade


if [ "/home/pi/ti-rpi" ]; then
    echo "ti-rpi installed. Updating."
    cd /home/pi/ti-rpi
    git pull
    sudo make install
else
    cd /home/pi
    git clone https://github.com/SequentMicrosystems/ti-rpi.git
    cd /home/pi/ti-rpi
    sudo make install
fi

if [ "/home/pi/megabas-rpi" ]; then
    echo "megabas-rpi installed. Updating."
    cd /home/pi/megabas-rpi
    git pull
    sudo make install
else
    cd /home/pi
    git clone https://github.com/SequentMicrosystems/megabas-rpi.git
    cd /home/pi/megabas-rpi
    sudo make install
fi

echo "I/O board watchdog set to 1 hour to prevent reboot during update."
ti wdtpwr 3600
# megabas 1 wdtpwr 3600

node-red-stop

cd /home/pi/ti-rpi/update/
if [[ $CHECK64 == *"aarch64"* ]]; then
  # For 64-bit OS use:
  ./update64
else    
  # For 32-bit OS use:
  ./update
fi


bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
sudo systemctl enable nodered.service

# sudo apt-get -y install mosquitto
sudo apt-get -y install pwgen
sudo apt-get -y install wget
sudo apt-get -y install zip
sudo apt-get -y install git
sudo apt-get -y install whiptail
sudo apt-get -y install xdotool
sudo apt-get -y install build-essential cmake
sudo apt-get -y install jq

if ! command -v mbus-serial-scan &> /dev/null
then
    
    echo "Installing M-Bus Libraries..."
    cd /home/pi
    sudo apt-get -y install git libtool libltdl-dev autoconf automake
    sudo git clone https://github.com/rscada/libmbus.git
    cd libmbus
    sudo sh clean.sh
    sudo sh build.sh
    make
    sudo make install
    sudo ln -s /usr/local/lib/libmbus.so.0 /usr/lib/libmbus.so.0

fi



if ! command -v docker &> /dev/null
then

    # INSTALL DOCKER (https://withblue.ink/2020/06/24/docker-and-docker-compose-on-raspberry-pi-os.html)
    # Install some required packages first

    sudo apt install -y \
         apt-transport-https \
         ca-certificates \
         curl \
         gnupg2 \
         software-properties-common

    # Get the Docker signing key for packages
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -

    # Add the Docker official repos
    echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
         $(lsb_release -cs) stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list

    # Install Docker
    sudo apt update
    sudo apt install -y --no-install-recommends \
        docker-ce \
        cgroupfs-mount

    sudo usermod -aG docker pi
    sudo systemctl enable --now docker

    # Replace with the latest version from https://github.com/docker/compose/releases/latest
    DOCKER_COMPOSE_VERSION="2.10.2"
    
    if [[ $CHECK64 == *"aarch64"* ]]; then
      # For 64-bit OS use:
      DOCKER_COMPOSE_ARCH="aarch64"
    else    
      # For 32-bit OS use:
      DOCKER_COMPOSE_ARCH="armv7"
    fi
    
    sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${DOCKER_COMPOSE_ARCH}" -o /usr/bin/docker-compose
    sudo chmod +x /usr/bin/docker-compose

fi



cd /home/pi
mkdir /home/pi/node-hiu
mkdir /home/pi/node-hiu/logs
mkdir /home/pi/node-hiu/flows
mkdir /home/pi/node-hiu/vpn
sudo chmod -R 775 /home/pi/node-hiu


CFILE=/boot/heatweb/config.json

if [ -f "$CFILE" ]; then
    echo "heatweb configuration file detected"
else

    sudo mkdir /boot/heatweb
    
    echo '{' > config.json
    echo '  "nodeId":"newnode",' >> config.json
    echo '  "networkId":"newnode",' >> config.json
    echo '  "name": "Zero Carbon Controller newnode",' >> config.json
    echo '  "description": "Heatweb Zero Carbon Controller Controller"' >> config.json
    echo '}' >> config.json
    
    sudo mv config.json /boot/heatweb/config.json
    
    cd /home/pi/.node-red
    node-red-stop

    cp /home/pi/plumbing-controller/node-red/settings.js /home/pi/.node-red/
    cp /home/pi/plumbing-controller/node-red/flows_ihiu.json /home/pi/.node-red/

    sudo npm install --unsafe-perm --build-from-source node-red-dashboard
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-arp
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-crypt
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-drawsvg
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-heatweb
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-m-bus
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-ui-level
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-ui-svg
    sudo npm install --unsafe-perm --build-from-source node-red-node-daemon
    sudo npm install --unsafe-perm --build-from-source node-red-node-email
    sudo npm install --unsafe-perm --build-from-source node-red-node-ui-table
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-pid
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-ip
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-uibuilder
    
    echo "Node-RED will restart, and the system will be given a new identity. During this process the system will reboot twice. Please wait at least 3 minutes before removing power."
    node-red-restart

fi

echo "IO board watchdog set to 60 secoonds to prevent reboot during update."
ti wdtpwr 60

echo "Finished."

