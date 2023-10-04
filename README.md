# plumbing-controller
Open Source Plumbing Controller for achieving net zero.

See https://hwwiki.ddns.net/


## Standard Installation for Raspberry Pi

    bash <(curl -sL https://raw.githubusercontent.com/heatweb/plumbing-controller/main/scripts/start.sh)
    
After the first run, the setup menu can be started with the following command:

    heatweb


## Setup Menu

![Main Menu](/media/heatweb-pc-mainmenu.PNG)

## Serialk Ports

485_1 -> /dev/ttyAMA1

485_2 -> /dev/ttyAMA4

M-Bus -> /dev/serial0 or /dev/ttyS0
