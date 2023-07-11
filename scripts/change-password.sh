#!/bin/bash

# Read Password

    whiptail --title "Change Password" --msgbox "Note this will restart Node-RED." 8 78

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


# Create heatweb folder if doesn't exist
[ ! -d "/boot/heatweb" ] && sudo mkdir /boot/heatweb

# Create credentials folder if doesn't exist
[ ! -d "/boot/heatweb/credentials" ] && sudo mkdir /boot/heatweb/credentials

echo $password > /home/pi/adminPassword.txt
sudo mv /home/pi/adminPassword.txt /boot/heatweb/credentials/adminPassword.txt

cd /home/pi/.node-red/
    # sudo npm install bcryptjs
    bcryptadminpass=$(node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" $password)
    node /home/pi/plumbing-controller/scripts/updateNodeRedPassword.js $bcryptadminpass
    echo "Restarting Node-RED, please wait."
    sleep 5s
    node-red-restart

    if ! command -v docker &> /dev/null
    then
        sudo docker exec mynodered1 node /home/pi/plumbing-controller/scripts/updateNodeRedPassword.js $bcryptadminpass /data/
        sudo docker restart mynodered1
        sleep 10s
    fi


echo "OS and Node-RED passwords updated."    
echo "Node-RED Restarted."    
echo "Password will not be applied until Composer is run."
whiptail --title "Admin Password" --msgbox "Password will not be applied until Setup Services is run." 8 78
