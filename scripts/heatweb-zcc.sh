#!/bin/bash


whiptail --title "Heatweb Plumbing Controller" --msgbox "/\/\/\/\    Heatweb Open-Source Plumbing Controller\n\ \ \ \/    Richard Hanson-Graville, Heatweb\n \/\/\/     03/01/2023\n\n            Apache 2.0 License" 15 73

mainmenu() {

        MYMENU=$(whiptail --title "Heatweb Plumbing Controller Setup" --menu \
                "\n   Move to selection (UP, DOWN) then press ENTER  " 19 73 10 \
                "install" "First installation                         " \
                "setup" "Software setup   " \
                "devices" "Connected devices   " \
                "exit" "Quit   " 3>&1 1>&2 2>&3)
}

while [[ $MYMENU != "exit" ]]
do
        mainmenu

        if [[ $MYMENU == "" ]]; then
            exit
        fi
        if [[ $MYMENU == "exit" ]]; then
            whiptail --title "Heatweb Plumbing Controller" --msgbox "Happy Days." 8 78
            exit
        fi
        
        if [[ $MYMENU == "install" ]]; then
            bash ~/plumbing-controller/scripts/rpi-setup.sh)
        fi
        
        if [[ $MYMENU == "setup" ]]; then
            # bash <(curl -sL https://raw.githubusercontent.com/heatweb/plumbing-controller/main/scripts/docker-setup.sh)
            bash ~/plumbing-controller/scripts/docker-setup.sh)
        fi
  
done


