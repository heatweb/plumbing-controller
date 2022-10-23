sudo apt-get install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox
sudo apt-get install --no-install-recommends chromium-browser

cd ~
wget https://www.waveshare.com/w/upload/7/75/CM4_dt_blob_Source.zip
unzip -o  CM4_dt_blob_Source.zip -d ./CM4_dt_blob_Source
sudo chmod 777 -R CM4_dt_blob_Source
cd CM4_dt_blob_Source/
sudo  dtc -I dts -O dtb -o /boot/dt-blob.bin dt-blob-disp0-double_cam.dts


sudo cat <<EOF > /etc/xdg/openbox/autostart
#!/bin/bash
# Disable any form of screen saver / screen blanking / power management
xset s off
xset s noblank
xset -dpms
# Allow quitting the X server with CTRL-ATL-Backspace
setxkbmap -option terminate:ctrl_alt_bksp
# Start Chromium in kiosk mode
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"[^"]\+"/"exit_type":"Normal"/' ~/.config/chromium/Default/Preferences
chromium-browser --start-fullscreen --kiosk --incognito --noerrdialogs --disable-translate --no-first-run --fast --fast-start --disable-infobars --disable-features=TranslateUI --disk-cache-dir=/dev/null  --password-store=basic --disable-pinch --overscroll-history-navigation=disabled --disable-features=TouchpadOverscrollHistoryNavigation 'http://localhost:1880/ui'
EOF
