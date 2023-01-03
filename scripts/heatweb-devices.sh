#!/bin/bash


# whiptail --title "Heatweb Plumbing Controller" --msgbox "/\/\/\/\    Heatweb Open-Source Plumbing Controller\n\ \ \ \/    Richard Hanson-Graville, Heatweb\n \/\/\/     03/01/2023\n\n            Apache 2.0 License" 15 73

BOARD=$(ti board)
echo $BOARD

mainmenu() {

        MYMENU=$(whiptail --title "Heatweb Plumbing Controller - Devices" --menu \
                "\n   Move to selection (UP, DOWN) then press ENTER  \n\n $BOARD" 19 73 10 \
                "TH1" "10K Resistance Sensor                   " \
                "EXIT" "Finished   " 3>&1 1>&2 2>&3)
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
        
        
  
done

