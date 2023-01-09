#!/bin/bash


whiptail --title "Heatweb Plumbing Controller" --msgbox "/\/\/\/\    Heatweb Open-Source Plumbing Controller\n\ \ \ \/    Richard Hanson-Graville, Heatweb\n \/\/\/     03/01/2023\n\n            Apache 2.0 License" 15 73

mainmenu() {

        MYMENU=$(whiptail --title "Heatweb Plumbing Controller" --menu \
                "\n   Move to selection (UP, DOWN) then press ENTER  " 19 73 10 \
                "UPDATE_GIT" "   Update files from GitHub                    " \
                "UPDATE_BOARD" "   Update I/O board                    " \
                "INSTALL" "   First installation                         " \
                "KIOSK" "   Activate kiosk browser   " \
                "APP" "   Select application   " \
                "PASSWORD" "   Set admin password                         " \
                "SETUP" "   Setup services   " \
                "COMPOSER" "   Compose application   " \
                "EXIT" "   Quit   " 3>&1 1>&2 2>&3)
}


#                "DEVICES" "   Connected devices   " \
#                "SETTINGS" "   Settings   " \
                
while [[ $MYMENU != "exit" ]]
do
        mainmenu

        if [[ $MYMENU == "" ]]; then
            exit
        fi
        if [[ $MYMENU == "EXIT" ]]; then
            # whiptail --title "Heatweb Plumbing Controller" --msgbox "Happy Days." 8 78
            exit
        fi
        
        if [[ $MYMENU == "UPDATE_GIT" ]]; then
            cd /home/pi/plumbing-controller
            sudo git pull
            sudo cp /home/pi/plumbing-controller/scripts/heatweb-zcc.sh /usr/local/bin/heatweb
            sudo chmod +x /usr/local/bin/heatweb
            #whiptail --title "Heatweb Plumbing Controller" --msgbox "Update complete. Press OK to restart." 8 78
            exec heatweb
        fi
        
        if [[ $MYMENU == "INSTALL" ]]; then
            bash /home/pi/plumbing-controller/scripts/rpi-setup.sh
        fi
        
        
        if [[ $MYMENU == "UPDATE_BOARD" ]]; then
            bash /home/pi/plumbing-controller/scripts/update-ti-rpi.sh
        fi
        
        if [[ $MYMENU == "SETUP" ]]; then
            # bash <(curl -sL https://raw.githubusercontent.com/heatweb/plumbing-controller/main/scripts/docker-setup.sh)
            bash /home/pi/plumbing-controller/scripts/docker-setup.sh
        fi
  
        if [[ $MYMENU == "PASSWORD" ]]; then
            bash /home/pi/plumbing-controller/scripts/change-password.sh
        fi
        
        if [[ $MYMENU == "KIOSK" ]]; then
            bash /home/pi/plumbing-controller/scripts/lcd-setup.sh
        fi
  
  
        if [[ $MYMENU == "APP" ]]; then
            bash /home/pi/plumbing-controller/scripts/select-application.sh
        fi
  
        if [[ $MYMENU == "COMPOSER" ]]; then
            sudo docker restart noderedsetup
            whiptail --title "Heatweb Plumbing Controller" --msgbox "Composer has been started. Please wait 1 minute for application to update." 8 78
            
        fi
  
        if [[ $MYMENU == "DEVICES" ]]; then
            bash /home/pi/plumbing-controller/scripts/heatweb-devices.sh
        fi
        
        
        if [[ $MYMENU == "SETTINGS" ]]; then
            bash /home/pi/plumbing-controller/scripts/heatweb-settings.sh
        fi
done


