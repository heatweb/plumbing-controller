#!/bin/bash

# Read Password


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

echo "Password will not be applied until Composer is run."
whiptail --title "Admin Password" --msgbox "Password will not be applied until Composer is run." 8 78
