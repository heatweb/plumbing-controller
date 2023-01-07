# Installation scripts

## rpi-setup.sh

Standard installation on a Raspberry Pi based system running a 64 bit operating system.


## change-setting.js

Usage: 

    node /home/pi/plumbing-controller/scripts/change-setting.js key value title units

Example:

    node /home/pi/plumbing-controller/scripts/change-setting.js postCode "CO10 2XW" "Postal Code"
    
    node /home/pi/plumbing-controller/scripts/change-setting.js tAlarm 60.0 "Alarm Temperature" "°C"
