sudo apt-get install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox
sudo apt-get install --no-install-recommends chromium-browser

cd ~
wget https://www.waveshare.com/w/upload/7/75/CM4_dt_blob_Source.zip
unzip -o  CM4_dt_blob_Source.zip -d ./CM4_dt_blob_Source
sudo chmod 777 -R CM4_dt_blob_Source
cd CM4_dt_blob_Source/
sudo  dtc -I dts -O dtb -o /boot/dt-blob.bin dt-blob-disp0-double_cam.dts

