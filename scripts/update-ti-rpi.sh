#!/bin/bash


CHECK64=$(uname -m)

if [ "/home/pi/ti-rpi" ]; then
    echo "ti-rpi installed. Updating."
    cd /home/pi/ti-rpi
    git pull
    sudo make install
else
    cd /home/pi
    git clone https://github.com/SequentMicrosystems/ti-rpi.git
    cd /home/pi/ti-rpi
    sudo make install
fi


echo "I/O board watchdog set to 1 hour to prevent reboot during update."
ti wdtpwr 3600
# megabas 1 wdtpwr 3600

node-red-stop

cd /home/pi/ti-rpi/update/
if [[ $CHECK64 == *"aarch64"* ]]; then
  # For 64-bit OS use:
  ./update64
else    
  # For 32-bit OS use:
  ./update
fi

node-red-restart

echo "IO board watchdog set to 60 secoonds to prevent reboot during update."
ti wdtpwr 60

echo "Finished."
