#!/bin/bash


whiptail --title "Heatweb Plumbing Controller" --msgbox "/\/\/\/\    Heatweb Open-Source Plumbing Controller\n\ \ \ \/    Richard Hanson-Graville, Heatweb\n \/\/\/     03/01/2023\n\n            Apache 2.0 License" 15 78

mainmenu() {

        MYMENU=$(whiptail --title "Heatweb Plumbing Controller Setup" --menu \
                "\n   Make selections (UP, DOWN, SPACE) then TAB to OK/Cancel " 19 73 10 \
                "gopipass" "Update Pi user password                         " \
                "gonrpass" "Update Node-RED admin password   " \
                "gocomposer" "Start Node-RED Composer   " \
                "goinflux" "Install InfluxDB database   " \
                "gomysql" "Install MySQL database   " \
                "goprom" "Install Prometheus " \
                "exit" "Quit   " 3>&1 1>&2 2>&3)
}

mainmenu

if [[ $MYMENU == "exit" ]]; then
    whiptail --title "Heatweb Plumbing Controller" --msgbox "Happy Days." 8 78
    exit
else
    mainmenu
fi