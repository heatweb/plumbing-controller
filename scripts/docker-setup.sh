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
cp -r /home/pi/plumbing-controller/mqtt /home/pi/mqtt
cp -r /home/pi/plumbing-controller/mqtt /home/pi/mqtt2
#cd /home/pi/mqtt

sudo docker network create mqtt
sudo docker run -d -it -p 1883:1883 --name=mqtt --restart=always -v /home/pi/mqtt/:/mosquitto/config/ --net mqtt eclipse-mosquitto:openssl
sudo docker run -d -it -p 10031:1883 --name=mqtt2 --restart=always -v /home/pi/mqtt2/:/mosquitto/config/ --net mqtt eclipse-mosquitto:openssl

#sudo docker run -d -it -p 5001:1880 -p 8001:8000 --net mqtt --restart=always -v node_red_data_1:/data -v /boot/heatweb/:/boot/heatweb/ --name mynodered1 heatweb/controller-setup
sudo docker run -d -it -p 5001:1880 -p 8001:8000 --net mqtt --restart=always -v node_red_data_1:/data -v /boot/heatweb/:/boot/heatweb/ --device /dev/ttyUSB0 --device /dev/ttyUSB1 --device /dev/ttyUSB2 --device /dev/ttyUSB3 --device /dev/ttyUSB4 --device /dev/ttyAMA1 --device /dev/ttyAMA2 --device /dev/ttyAMA3 --device /dev/ttyAMA4 --name mynodered1 heatweb/plumbing-controller:latest

sudo docker run \
    -v /home/pi:/srv \
    -p 8090:80 \
    --name filebrowser \
    filebrowser/filebrowser

sudo docker run -d -p 3000:3000 --name=mygrafana --restart=always --net mqtt -v grafana-storage:/var/lib/grafana grafana/grafana-oss

#sudo docker run -d --name mysql --net mqtt -v mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mysql-password -d mysql:latest
#sudo docker run --name phpmyadmin -d --net mqtt --link mysql:db -p 8081:80 phpmyadmin:latest
#sudo docker run --name phpmyadmin -d --net mqtt --link mysql:db -p 8081:80 arm64v8/phpmyadmin

sudo docker run -d -p 8086:8086 --name influxdb --net mqtt \
      -v influx_data:/var/lib/influxdb2 \
      -v influx_config:/etc/influxdb2 \
      -e DOCKER_INFLUXDB_INIT_MODE=setup \
      -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
      -e DOCKER_INFLUXDB_INIT_PASSWORD=Your_Password \
      -e DOCKER_INFLUXDB_INIT_ORG=heatweb \
      -e DOCKER_INFLUXDB_INIT_BUCKET=heatweb \
      -e DOCKER_INFLUXDB_INIT_RETENTION=1w \
      influxdb:2.0

sudo docker exec influxdb influx auth list \
      --user admin \
      --hide-headers | cut -f 3
