# For 64-bit OS (can be changed via comments)

sudo apt-get -y update

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
# For 64-bit OS use:
DOCKER_COMPOSE_ARCH="aarch64"
# For 32-bit OS use:
#DOCKER_COMPOSE_ARCH="armv7"

sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${DOCKER_COMPOSE_ARCH}" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

cd ~
git clone https://github.com/heatweb/plumbing-controller.git
cd /home/pi/plumbing-controller
git pull
cp -r /home/pi/plumbing-controller/mqtt/ /home/pi/
#cd /home/pi/mqtt

sudo docker network create mqtt
sudo docker run -d -it -p 1883:1883 --name=mqtt --restart=always -v /home/pi/mqtt/:/mosquitto/config/ --net mqtt eclipse-mosquitto:openssl

sudo docker run -d -it -p 5001:1880 -p 8001:8000 --net mqtt --restart=always -v node_red_data_1:/data -v /boot/heatweb/:/boot/heatweb/ --name mynodered1 heatweb/test-image
