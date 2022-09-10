# For 64-bit OS (can be changed via comments)

sudo apt-get -y update
sudo apt-get -y upgrade
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
sudo systemctl enable nodered.service
sudo apt-get -y install mosquitto
sudo apt-get -y install pwgen
sudo apt-get -y install wget
sudo apt-get -y install zip
sudo apt-get -y install git
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
mkdir /home/pi/node-hiu
mkdir /home/pi/node-hiu/logs
mkdir /home/pi/node-hiu/iHIU
mkdir /home/pi/node-hiu/flows
sudo chmod -R 775 /home/pi/node-hiu
sudo mkdir /boot/heatweb

cd ~
git clone https://github.com/SequentMicrosystems/ti-rpi.git
cd ti-rpi/
sudo make install
cd ~
git clone https://github.com/SequentMicrosystems/megabas-rpi.git
cd /home/pi/megabas-rpi
sudo make install

cd /home/pi/.node-red
node-red-stop
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
node-red-restart

# INSTALL DOCKER (https://withblue.ink/2020/06/24/docker-and-docker-compose-on-raspberry-pi-os.html)
# Install some required packages first
sudo apt update
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
    
sudo systemctl enable --now docker

# Replace with the latest version from https://github.com/docker/compose/releases/latest
DOCKER_COMPOSE_VERSION="2.10.2"
# For 64-bit OS use:
DOCKER_COMPOSE_ARCH="aarch64"
# For 32-bit OS use:
#DOCKER_COMPOSE_ARCH="armv7"

sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${DOCKER_COMPOSE_ARCH}" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
