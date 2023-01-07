#!/bin/bash

if ! command -v jq &> /dev/null
then
        sudo apt-get -y install jq
fi

mainmenu() {

        MYMENU=$(whiptail --title "Heatweb Plumbing Controller - Settings" --menu \
                "\n   Move to selection (UP, DOWN) then press ENTER  " 19 73 10 \
                "SETTINGS" "   Settings   " \
                "EXIT" "   Quit   " 3>&1 1>&2 2>&3)
}

while [[ $MYMENU != "exit" ]]
do
        mainmenu

        if [[ $MYMENU == "" ]]; then
            exit
        fi
        if [[ $MYMENU == "EXIT" ]]; then
            exit
        fi
        
       
        
        if [[ $MYMENU == "SETTINGS" ]]; then
            C_SET=$(node /home/pi/plumbing-controller/scripts/list-settings.js)
            echo $C_SET
            SETMENU=$(whiptail --title "Heatweb Plumbing Controller - Settings" --menu \
                "\n   Move to selection (UP, DOWN) then press ENTER  " 19 73 10 \
                --cancel-button Cancel \
                --ok-button Select $C_SET 3>&1 1>&2 2>&3)
            
        fi
done

