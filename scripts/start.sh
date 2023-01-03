#!/bin/bash

cd /home/pi
git clone https://github.com/heatweb/plumbing-controller.git
cd /home/pi/plumbing-controller
git pull
sudo cp /home/pi/plumbing-controller/scripts/heatweb-zcc.sh /usr/local/bin/heatweb
sudo chmod +x /usr/local/bin/heatweb
heatweb
