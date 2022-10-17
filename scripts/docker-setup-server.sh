#!/bin/bash
# Read Password
echo -n "Admin password:"
read -s password
echo
echo -n "Repeat password:"
read -s password2
echo
if [[ "$password" == "$password2" ]]; then
 echo "ok"
else
 echo "Passwords do not match."
 exit 1
fi

read -p "Do you want to install InfluxDB database? (y/n) " goinflux
read -p "Do you want to install MySQL database? (y/n) " gomysql
read -p "System username? " username

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
    


sudo usermod -aG docker $username
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

sudo apt-get install -y git
cd ~
git clone https://github.com/heatweb/plumbing-controller.git
cd /home/$username/plumbing-controller
git pull
cp -r /home/$username/plumbing-controller/mqtt /home/$username/mqtt
#cp -r /home/$username/plumbing-controller/mqtt /home/$username/mqtt2

sudo docker network create mqtt
sudo docker run -d -it -p 10031:1883 --name=mqtt --restart=always -v /home/$username/mqtt/:/mosquitto/config/ --net mqtt eclipse-mosquitto:openssl
#sudo docker run -d -it -p 10032:1883 --name=mqtt2 --restart=always -v /home/$username/mqtt2/:/mosquitto/config/ --net mqtt eclipse-mosquitto:openssl

sudo docker run -d -it -p 5001:1880 -p 8001:8000 --net mqtt --restart=always -v node_red_data_1:/data --name mynodered1 nodered/node-red

sudo docker run -d \
    -v /home/$username:/srv \
    -p 8090:80 \
    --name filebrowser \
    filebrowser/filebrowser

sudo docker run -d -p 3000:3000 --name=grafana --restart=always --net mqtt -v grafana-storage:/var/lib/grafana grafana/grafana-oss


case $gomysql in
  [Yy]* ) 

     sudo docker run -d --name mysql --net mqtt -p 3306:3306 -v mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$password -d mysql:latest
     sudo docker run --name phpmyadmin -d --net mqtt --link mysql:db -p 7000:80 phpmyadmin:latest
  ;;

esac

case $goinflux in
  [Yy]* ) 

    sudo docker run -d -p 8086:8086 --name influxdb --net mqtt \
      -v influx_data:/var/lib/influxdb2 \
      -v influx_config:/etc/influxdb2 \
      -e DOCKER_INFLUXDB_INIT_MODE=setup \
      -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
      -e DOCKER_INFLUXDB_INIT_PASSWORD=$password \
      -e DOCKER_INFLUXDB_INIT_ORG=heatweb \
      -e DOCKER_INFLUXDB_INIT_BUCKET=heatweb \
      -e DOCKER_INFLUXDB_INIT_RETENTION=1y \
      influxdb:2.0
  ;;

esac


echo "Please wait 1 minute to complete..."
sleep 1m

case $goinflux in
  [Yy]* ) 
     
    sudo docker exec influxdb influx auth list \
          --user admin \
          --hide-headers | cut -f 3 > /home/$username/influxdbtoken.txt
          
    echo -n "Your InfluxDB access token is: "
    cat /home/$username/influxdbtoken.txt
    echo "This is saved to /home/$username/influxdbtoken.txt"
 ;;
esac

sudo docker exec -ti grafana grafana-cli admin reset-admin-password $password

## The following lines add the admin user to the MQTT service and restarts it.
sudo docker exec -ti mqtt mosquitto_passwd -b /mosquitto/config/passwordfile admin $password
sudo docker restart mqtt

echo "Finished."
echo "IMPORTANT: You should go to Portainer on port 9000, set the admin password, and click on Get Started.
