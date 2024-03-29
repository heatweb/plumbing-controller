#!/bin/bash


whiptail --title "Heatweb Plumbing Controller Setup" --msgbox "/\/\/\/\    Open-Source Plumbing Controller\n\ \ \ \/    Richard Hanson-Graville, Heatweb\n \/\/\/     31/12/2022\n\n            Apache 2.0 License" 15 78




# Read Password

CHECK64=$(uname -m)



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

    whiptail --title "Docker Installed" --msgbox "Docker has been installed. The system will to be rebooted before continuing." 8 78
    exit
fi



# Thanks to Peter Scargill for the Script. https://bitbucket.org/scargill/workspace/snippets/kAR5qG/the-script 
MYMENU=$(whiptail --title "Heatweb Plumbing Controller Setup" --checklist \
        "\n   Make selections (UP, DOWN, SPACE) then TAB to OK/Cancel " 19 73 10 \
        "gopipass" "Update pi user password                         " ON \
        "gonrpass" "Update Node-RED admin password   " ON \
        "goportpass" "Renew Portainer password   " OFF \
        "goinflux" "Install InfluxDB database   " OFF \
        "gomysql" "Install MySQL database   " OFF \
        "goprom" "Install Prometheus " OFF \
        "gocomposer" "Run Composer when complete   " OFF \
        "gorenew" "Remove all existing containers   " OFF 3>&1 1>&2 2>&3)
        
 if [[ $MYMENU == "" ]]; then
    whiptail --title "Installation Aborted" --msgbox "Cancelled as requested." 8 78
    exit
fi


# Create heatweb folder if doesn't exist
[ ! -d "/boot/heatweb" ] && sudo mkdir /boot/heatweb

# Create credentials folder if doesn't exist
[ ! -d "/boot/heatweb/credentials" ] && sudo mkdir /boot/heatweb/credentials

# Create ports folder if doesn't exist
[ ! -d "/boot/heatweb/ports" ] && sudo mkdir /boot/heatweb/ports


if [ -f "/boot/heatweb/credentials/adminPassword.txt" ]; then

        password=$(cat /boot/heatweb/credentials/adminPassword.txt)

else

    password=$(whiptail --passwordbox "Enter admin password" 8 60 3>&1 1>&2 2>&3)
      if [[ -z "${password// }" ]]; then
          printf "No password given - aborting\r\n"; exit
      fi
    password2=$(whiptail --passwordbox "Repeat admin password" 8 60 3>&1 1>&2 2>&3)


    if [[ "$password" != "$password2" ]]; then
     echo "Passwords do not match."
     whiptail --title "Admin Password" --msgbox "Passwords do not match." 8 78
     exit 1
    fi


    echo $password > /home/pi/adminPassword.txt
    sudo mv /home/pi/adminPassword.txt /boot/heatweb/credentials/adminPassword.txt

fi 

#echo "Password is currently $password."


if [[ $MYMENU == *"gorenew"* ]]; then
 docker rm -f $(docker ps -aq)
fi 
 


sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

cd /home/pi
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
sudo docker run -d -it -p 5001:1880 -p 8001:8000 --net mqtt --restart=always --add-host=host.docker.internal:host-gateway -v node_red_data_1:/data -v /home/pi/:/home/pi/ -v /boot/heatweb/config.json:/boot/heatweb/config.json --privileged --device /dev/ttyAMA1 --device /dev/ttyAMA2 --device /dev/ttyAMA3 --device /dev/ttyAMA4 --name mynodered1 heatweb/plumbing-controller:latest

sudo docker run -d \
    -v /home/pi:/srv \
    -p 8090:80 \
    --name filebrowser \
    filebrowser/filebrowser

sudo docker run -d -p 3000:3000 --name=grafana --restart=always --net mqtt --add-host=host.docker.internal:host-gateway -v grafana-storage:/var/lib/grafana grafana/grafana-oss

if [[ $MYMENU == *"gomysql"* ]]; then

     sudo docker run -d --name mysql --restart=always --net mqtt -p 3306:3306 -v mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$password -d mysql:latest
     #sudo docker run --name phpmyadmin -d --restart=always --net mqtt --link mysql:db -p 8081:80 phpmyadmin:latest
     sudo docker run --name phpmyadmin -d --restart=always --net mqtt --link mysql:db -p 8081:80 arm64v8/phpmyadmin
  
fi

if [[ $MYMENU == *"goprom"* ]]; then

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

fi

if [[ $MYMENU == *"goinflux"* ]]; then

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
    sudo mv /home/pi/localInfluxPassword.txt /boot/heatweb/credentials/localInfluxPassword.txt

fi

if [[ $MYMENU == *"goportpass"* ]]; then

        docker stop portainer
        docker pull portainer/helper-reset-password
        #docker run --rm -v portainer_data:/data portainer/helper-reset-password > /home/pi/portainerPassword.txt
        docker run --rm -v portainer_data:/data portainer/helper-reset-password 2>&1 | tee -a /home/pi/portainerLog.txt
        sudo grep login /home/pi/portainerLog.txt | sed 's/.*login:\s//g' > /home/pi/portainerPassword.txt
        echo "A new password has been given to Portainer:"
        cat /home/pi/portainerPassword.txt
        sudo cp /home/pi/portainerPassword.txt /boot/heatweb/credentials/portainerPassword.txt
        sudo rm /home/pi/portainerLog.txt
        sudo rm /home/pi/portainerPassword.txt
        docker start portainer
        echo "Portainer has been started on port 9000."

fi

echo "Please wait 1 minute to complete..."
sleep 1m


sudo docker exec -ti grafana grafana-cli admin reset-admin-password $password
echo $password > /home/pi/grafanaPassword.txt
sudo mv /home/pi/grafanaPassword.txt /boot/heatweb/credentials/grafanaPassword.txt

sudo docker exec -ti grafana grafana-cli plugins install aceiot-svg-panel
sudo docker exec -ti grafana grafana-cli plugins install marcuscalidus-svg-panel
sudo docker exec -ti grafana grafana-cli plugins install marcusolsson-static-datasource
sudo docker exec -ti grafana grafana-cli plugins install volkovlabs-image-panel
sudo docker restart grafana

## The following lines add the admin user to the MQTT service and restarts it.
sudo docker exec -ti mqtt mosquitto_passwd -b /mosquitto/config/passwordfile admin $password
sudo docker restart mqtt
echo $password > /home/pi/localMqttPassword.txt
sudo mv /home/pi/localMqttPassword.txt /boot/heatweb/credentials/localMqttPassword.txt

if [[ $MYMENU == *"goinflux"* ]]; then

    sudo docker exec influxdb influx auth list \
          --user admin \
          --hide-headers | cut -f 3 > /home/pi/localInfluxToken.txt
          
    echo -n "Your InfluxDB access token is: "
    cat /home/pi/localInfluxToken.txt
    echo "This is saved to /boot/heatweb/credentials/localInfluxToken.txt"
    sudo mv /home/pi/localInfluxToken.txt /boot/heatweb/credentials/localInfluxToken.txt
fi

if [[ $MYMENU == *"gopipass"* ]]; then
  
     echo "pi:$password" | sudo chpasswd
fi


if [[ $MYMENU == *"gonrpass"* ]]; then
  
    cd /home/pi/.node-red/
    # sudo npm install bcryptjs
    bcryptadminpass=$(node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" $password)
    node /home/pi/plumbing-controller/scripts/updateNodeRedPassword.js $bcryptadminpass
    echo "Restarting Node-RED, please wait."
    sleep 5s
    node-red-restart
    
    sudo docker exec mynodered1 node /home/pi/plumbing-controller/scripts/updateNodeRedPassword.js $bcryptadminpass /data/
    sudo docker restart mynodered1
    sleep 10s
    
fi



if [[ $MYMENU == *"gocomposer"* ]]; then
  
  node /home/pi/plumbing-controller/scripts/flow-composer/flow-composer.js /boot/heatweb/composer/composer.json
  whiptail --title "Heatweb Plumbing Controller" --msgbox "Composer has been finished. \nApplication should be running in Node-RED on port 1880." 8 78
  
fi


echo "Finished."

    
