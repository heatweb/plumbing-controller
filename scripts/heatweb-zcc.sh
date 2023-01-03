#!/bin/bash


whiptail --title "Heatweb Plumbing Controller" --msgbox "/\/\/\/\    Heatweb Open-Source Plumbing Controller\n\ \ \ \/    Richard Hanson-Graville, Heatweb\n \/\/\/     03/01/2023\n\n            Apache 2.0 License" 15 73

mainmenu() {

        MYMENU=$(whiptail --title "Heatweb Plumbing Controller" --menu \
                "\n   Move to selection (UP, DOWN) then press ENTER  " 19 73 10 \
                "UPDATE" "Update files from GitHub                    " \
                "INSTALL" "First installation                         " \
                "SETUP" "Software setup   " \
                "DEVICES" "Connected devices   " \
                "EXIT" "Quit   " 3>&1 1>&2 2>&3)
}

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
        
        if [[ $MYMENU == "UPDATE" ]]; then
            cd /home/pi/plumbing-controller
            git pull
            sudo cp plumbing-controller/scripts/heatweb-zcc.sh /usr/local/bin/heatweb-zcc
            sudo chmod +x /usr/local/bin/heatweb-zcc
            whiptail --title "Heatweb Plumbing Controller" --msgbox "Update complete. Restarting." 8 78
            exec heatweb-zcc
        fi
        
        if [[ $MYMENU == "INSTALL" ]]; then
            bash /home/pi/plumbing-controller/scripts/rpi-setup.sh
        fi
        
        if [[ $MYMENU == "SETUP" ]]; then
            # bash <(curl -sL https://raw.githubusercontent.com/heatweb/plumbing-controller/main/scripts/docker-setup.sh)
            bash /home/pi/plumbing-controller/scripts/docker-setup.sh
        fi
  
done


