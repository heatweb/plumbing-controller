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


if [ ! -f /home/pi/node-hiu/install.txt ]; then
    echo "Very first run."
        
    cd /home/pi
    mkdir /home/pi/node-hiu
    mkdir /home/pi/node-hiu/logs
    mkdir /home/pi/node-hiu/flows
    mkdir /home/pi/node-hiu/vpn
    sudo chmod -R 775 /home/pi/node-hiu

    echo "Installation Started" > /home/pi/node-hiu/install.txt
    
    if [[ $CHECK64 == *"aarch64"* ]]; then
      # For 64-bit OS use:
      sudo mv /boot/config.txt /boot/x_config.txt
      sudo cp /home/pi/plumbing-controller/scripts/boot/config.txt /boot/config.txt

      echo "System will reboot. Please run Heatweb First Install (again) once reboot has completed."
      echo "First reboot with new config.txt" >> /node-hiu/install.txt
      sudo reboot
      
    fi

fi



sudo apt-get -y update
sudo apt-get -y upgrade


sudo apt-get -y install mosquitto
sudo apt-get -y install pwgen
sudo apt-get -y install wget
sudo apt-get -y install zip
sudo apt-get -y install git
sudo apt-get -y install whiptail
sudo apt-get -y install xdotool
sudo apt-get -y install build-essential cmake
sudo apt-get -y install jq


if [ -d "/home/pi/ti-rpi" ]; then
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

if [ -d "/home/pi/megabas-rpi" ]; then
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

CHECKBRD=$(ti board)
if [[ $CHECKBRD == *"not detected"* ]]; then
    echo "TI BOARD NOT DETECTED"
else
    
    echo "TI BOARD DETECTED"
    echo $CHECKBRD
    cd /home/pi/ti-rpi/update/
    if [[ $CHECK64 == *"aarch64"* ]]; then
      # For 64-bit OS use:
      ./update64
    else    
      # For 32-bit OS use:
      ./update
    fi
fi


bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
sudo systemctl enable nodered.service

cd /home/pi/.node-red/
sudo npm install bcryptjs


if ! command -v mbus-serial-scan &> /dev/null
then
    
    echo "Installing M-Bus Libraries..."
    cd /home/pi
    sudo apt-get -y install git libtool libltdl-dev autoconf automake
    sudo git clone https://github.com/rscada/libmbus.git
    cd libmbus
    sudo sh clean.sh
    sudo sh build.sh
    sudo make
    sudo make install
    sudo ln -s /usr/local/lib/libmbus.so.0 /usr/lib/libmbus.so.0

fi






if [ -f "/boot/heatweb/config.json" ]; then
    echo "heatweb configuration file detected"
    
else

    cd /home/pi
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
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-influxdb
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-crypt
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-drawsvg
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-heatweb
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-m-bus
    sudo npm install --unsafe-perm --build-from-source node-red-contrib-modbus
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

