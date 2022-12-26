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
read -p "Do you want to install Prometheus? (y/n) " goprom


read -p "Do you want to overwrite existing setup? (y/n) " gorenew


[ ! -d "/boot/heatweb/credentials" ] && sudo mkdir /boot/heatweb/credentials

echo $password > /home/pi/adminPassword.txt
sudo mv /home/pi/adminPassword.txt /boot/heatweb/credentials/adminPassword.txt


# For 64-bit OS (can be changed via comments)

sudo apt-get -y update

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
    # For 64-bit OS use:
    DOCKER_COMPOSE_ARCH="aarch64"
    # For 32-bit OS use:
    #DOCKER_COMPOSE_ARCH="armv7"

    sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${DOCKER_COMPOSE_ARCH}" -o /usr/bin/docker-compose
    sudo chmod +x /usr/bin/docker-compose

fi

case $gorenew in
  [Yy]* ) 
  
     docker rm -f $(docker ps -aq)
  ;;

esac



sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

cd ~
git clone https://github.com/heatweb/plumbing-controller.git
cd /home/pi/plumbing-controller
git pull
cp -r /home/pi/plumbing-controller/mqtt /home/pi/mqtt
#cp -r /home/pi/plumbing-controller/mqtt /home/pi/mqtt2

sudo apt-get remove -y mosquitto
sudo docker network create mqtt
sudo docker run -d -it -p 1883:1883 --name=mqtt --restart=always -v /home/pi/mqtt/:/mosquitto/config/ --net mqtt eclipse-mosquitto:openssl
#sudo docker run -d -it -p 10031:1883 --name=mqtt2 --restart=always -v /home/pi/mqtt2/:/mosquitto/config/ --net mqtt eclipse-mosquitto:openssl

#sudo docker run -d -it -p 5001:1880 -p 8001:8000 --net mqtt --restart=always -v node_red_data_1:/data -v /boot/heatweb/:/boot/heatweb/ --name mynodered1 heatweb/controller-setup
#sudo docker run -d -it -p 5001:1880 -p 8001:8000 --net mqtt --restart=always -v node_red_data_1:/data -v /boot/heatweb/:/boot/heatweb/ --device /dev/ttyUSB0 --device /dev/ttyUSB1 --device /dev/ttyUSB2 --device /dev/ttyUSB3 --device /dev/ttyUSB4 --device /dev/ttyAMA1 --device /dev/ttyAMA2 --device /dev/ttyAMA3 --device /dev/ttyAMA4 --name mynodered1 heatweb/plumbing-controller:latest
sudo docker run -d -it -p 5001:1880 -p 8001:8000 --net mqtt --restart=always --add-host=host.docker.internal:host-gateway -v node_red_data_1:/data -v /boot/heatweb/:/boot/heatweb/ --privileged --device /dev/ttyAMA1 --device /dev/ttyAMA2 --device /dev/ttyAMA3 --device /dev/ttyAMA4 --name mynodered1 heatweb/plumbing-controller:latest

sudo docker run -d \
    -v /home/pi:/srv \
    -p 8090:80 \
    --name filebrowser \
    filebrowser/filebrowser

sudo docker run -d -p 3000:3000 --name=grafana --restart=always --net mqtt --add-host=host.docker.internal:host-gateway -v grafana-storage:/var/lib/grafana grafana/grafana-oss


case $gomysql in
  [Yy]* ) 

     sudo docker run -d --name mysql --restart=always --net mqtt -p 3306:3306 -v mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$password -d mysql:latest
     #sudo docker run --name phpmyadmin -d --restart=always --net mqtt --link mysql:db -p 8081:80 phpmyadmin:latest
     sudo docker run --name phpmyadmin -d --restart=always --net mqtt --link mysql:db -p 8081:80 arm64v8/phpmyadmin
  ;;

esac


case $goprom in
  [Yy]* ) 

    cp -r /home/pi/plumbing-controller/prometheus /home/pi/prometheus
    
    docker run -d --restart=always --net mqtt \
    --name=prometheus \
    -p 9099:9090 \
    --add-host=host.docker.internal:host-gateway \
    -v ~/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus \
    --storage.tsdb.retention.time=365d \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus \
    --web.console.libraries=/usr/share/prometheus/console_libraries \
    --web.console.templates=/usr/share/prometheus/consoles

  ;;

esac

case $goinflux in
  [Yy]* ) 

    sudo docker run -d -p 8086:8086 --name influxdb --restart=always --net mqtt \
      -v influx_data:/var/lib/influxdb2 \
      -v influx_config:/etc/influxdb2 \
      -e DOCKER_INFLUXDB_INIT_MODE=setup \
      -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
      -e DOCKER_INFLUXDB_INIT_PASSWORD=$password \
      -e DOCKER_INFLUXDB_INIT_ORG=heatweb \
      -e DOCKER_INFLUXDB_INIT_BUCKET=heatweb \
      -e DOCKER_INFLUXDB_INIT_RETENTION=53w \
      influxdb:2.0
      
    echo $password > /home/pi/localInfluxPassword.txt
    sudo mv /home/pi/adminPassword.txt /boot/heatweb/credentials/localInfluxPassword.txt
  ;;

esac


echo "Please wait 1 minute to complete..."
sleep 1m


sudo docker exec -ti grafana grafana-cli admin reset-admin-password $password

## The following lines add the admin user to the MQTT service and restarts it.
sudo docker exec -ti mqtt mosquitto_passwd -b /mosquitto/config/passwordfile admin $password
sudo docker restart mqtt
echo $password > /home/pi/localMqttPassword.txt
sudo mv /home/pi/adminPassword.txt /boot/heatweb/credentials/localMqttPassword.txt

case $goinflux in
  [Yy]* ) 
     
    sudo docker exec influxdb influx auth list \
          --user admin \
          --hide-headers | cut -f 3 > /home/pi/localInfluxToken.txt
          
    echo -n "Your InfluxDB access token is: "
    cat /home/pi/localInfluxToken.txt
    echo "This is saved to /boot/heatweb/credentials/localInfluxToken.txt"
    sudo mv /home/pi/localInfluxToken.txt /boot/heatweb/credentials/localInfluxToken.txt
 ;;
esac

echo "Finished."
echo "IMPORTANT: You should go to Portainer on port 9000, set the admin password, and click on Get Started."
