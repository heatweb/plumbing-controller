#!/bin/bash


whiptail --title "Heatweb Plumbing Controller" --msgbox "/\/\/\/\    Heatweb Open-Source Plumbing Controller\n\ \ \ \/    Richard Hanson-Graville, Heatweb\n \/\/\/     03/01/2023\n\n            Apache 2.0 License" 15 78



MYMENU=$(whiptail --title "Heatweb Plumbing Controller Setup" --checklist \
        "\n   Make selections (UP, DOWN, SPACE) then TAB to OK/Cancel " 19 73 10 \
        "gopipass" "Update Pi user password                         " ON \
        "gonrpass" "Update Node-RED admin password   " ON \
        "gocomposer" "Start Node-RED Composer   " ON \
        "goinflux" "Install InfluxDB database   " ON \
        "gomysql" "Install MySQL database   " OFF \
        "goprom" "Install Prometheus " OFF \
        "gorenew" "Remove all existing containers   " OFF 3>&1 1>&2 2>&3)
        
 if [[ $MYMENU == "" ]]; then
    whiptail --title "Installation Aborted" --msgbox "Cancelled as requested." 8 78
    exit
fi
