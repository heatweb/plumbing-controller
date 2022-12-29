# For 64-bit OS (can be changed via comments)

read -p "Network Identity: " netname

sudo apt-get -y update
sudo apt-get -y upgrade
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
echo "Installing M-Bus Libraries..."
sudo apt-get -y install git libtool libltdl-dev autoconf automake
sudo git clone https://github.com/rscada/libmbus.git
cd libmbus
sudo sh clean.sh
sudo sh build.sh
make
sudo make install
sudo ln -s /usr/local/lib/libmbus.so.0 /usr/lib/libmbus.so.0

cd ~
mkdir /home/pi/node-hiu
mkdir /home/pi/node-hiu/logs
#mkdir /home/pi/node-hiu/iHIU
mkdir /home/pi/node-hiu/flows
mkdir /home/pi/node-hiu/vpn
sudo chmod -R 775 /home/pi/node-hiu
sudo mkdir /boot/heatweb

sudo cat <<EOF > config.json
{
 "nodeId":"newnode",
 "networkId":"$netname",
 "name": "Zero Carbon Controller newnode",
 "description": "Heatweb Zero Carbon Controller Controller"
}
EOF

sudo mv config.json /boot/heatweb/config.json

cd ~
git clone https://github.com/SequentMicrosystems/ti-rpi.git
cd ti-rpi/
sudo make install

cd ~
git clone https://github.com/SequentMicrosystems/megabas-rpi.git
cd /home/pi/megabas-rpi
sudo make install

cd ~
git clone https://github.com/heatweb/plumbing-controller.git
cd /home/pi/plumbing-controller

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


# INSTALL DOCKER (https://withblue.ink/2020/06/24/docker-and-docker-compose-on-raspberry-pi-os.html)
echo "Installing Docker and Deploying Containers..."
bash <(curl -sL https://raw.githubusercontent.com/heatweb/plumbing-controller/main/scripts/docker-setup.sh)

echo "Node-RED will restart, and the system will be given a new identity. During this process the system will reboot twice. Please wait at least 3 minutes before removing power."
node-red-restart
