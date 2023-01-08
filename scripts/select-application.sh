#!/bin/bash

: '
Adapted from filebrowse.sh written by Claude Pageau

This is a whiptail file browser that allows navigating through a directory
structure and select a specified file type per filext variable.
It Returns a filename path if selected.  Esc key exits.
'

startdir="/home/pi/plumbing-controller/applications"
filext='composer.json'
menutitle="$filext Application File Selection Menu"

#------------------------------------------------------------------------------
function Filebrowser()
{
# first parameter is Menu Title
# second parameter is optional dir path to starting folder
# otherwise current folder is selected

    if [ -z $2 ] ; then
        dir_list=$(ls -lhp -I "*.md"  | awk -F ' ' ' { print $9 " " $5 } ')
    else
        cd "$2"
        dir_list=$(ls -lhp -I "*.md"  | awk -F ' ' ' { print $9 " " $5 } ')
    fi

    curdir=$(pwd)
    basedir="/home/pi/plumbing-controller/applications"
    #secondString="> "
    secondString=" "
    curdirtxt="${curdir/"$basedir"/"$secondString"}" 
    curdirtxt="${curdirtxt//\// "\n"   \+ }" 
    
    if [ "$curdir" == "$startdir" ] ; then  # Check if you are at root folder
        selection=$(whiptail --title "$1" \
                              --menu "\n Please select an application directory. \n $curdirtxt" 0 73 0 \
                              --cancel-button Cancel \
                              --ok-button Select "../                                             " BACK $dir_list 3>&1 1>&2 2>&3)
    else   # Not Root Dir so show ../ BACK Selection in Menu
        selection=$(whiptail --title "$1" \
                              --menu "\n Please select an application composer.json file. \n $curdirtxt" 0 73 0 \
                              --cancel-button Cancel \
                              --ok-button Select "../                                             " BACK $dir_list 3>&1 1>&2 2>&3)
    fi

    RET=$?
    if [ $RET -eq 1 ]; then  # Check if User Selected Cancel
       return 1
    elif [ $RET -eq 0 ]; then
       if [[ -d "$selection" ]]; then  # Check if Directory Selected
          Filebrowser "$1" "$selection"
       elif [[ "$selection" == "../                                             " ]]; then  # Check if BACK with spaces
          if [ "$curdir" != "$startdir" ] ; then 
            Filebrowser "$1" "../"
          else
            Filebrowser "$1" "./"
          fi
       elif [[ -f "$selection" ]]; then  # Check if File Selected
          if [[ $selection == *$filext ]]; then   # Check if selected File has .jpg extension
            if (whiptail --title "Confirm Selection" --yesno "DirPath : $curdir\nFileName: $selection" 0 0 \
                         --yes-button "Confirm" \
                         --no-button "Retry"); then
                filename="$selection"
                filepath="$curdir"    # Return full filepath  and filename as selection variables
            else
                Filebrowser "$1" "$curdir"
            fi
          else   # Not correct extension so Inform User and restart
             whiptail --title "ERROR: File Must have $filext Extension" \
                      --msgbox "$selection\nYou Must Select a $filext file" 0 0
             Filebrowser "$1" "$curdir"
          fi
       else
          # Could not detect a file or folder so Try Again
          whiptail --title "ERROR: Selection Error" \
                   --msgbox "Error Changing to Path $selection" 0 0
          Filebrowser "$1" "$curdir"
       fi
    fi
}


Filebrowser "$menutitle" "$startdir"

exitstatus=$?
if [ $exitstatus -eq 0 ]; then
    if [ "$selection" == "" ]; then
        echo "User Pressed Esc with No File Selection"
    else
#        whiptail --title "File was selected" --msgbox " \
#
#        File Selected information
#
#        Filename : $filename
#        Directory: $filepath
#
#        \
#        " 0 0 0
        echo "Result is"
        echo "$filepath/$filename"
        
        node /home/pi/plumbing-controller/scripts/change-setting.js appFile "$filename" "Application Composer JSON file"
        node /home/pi/plumbing-controller/scripts/change-setting.js appPath "$filepath" "Application Composer path"
        
        sudo rm -r /boot/heatweb/composer        
        sudo mkdir /boot/heatweb/composer
        sudo cp -r $filepath/* /boot/heatweb/composer
        #sudo chown -R pi:pi /home/pi/node-hiu/composer
        echo "Copied to /boot/heatweb/composer/"
        
        
        if [ -f "/boot/heatweb/composer/install.sh" ]; then
            bash /boot/heatweb/composer/install.sh
        fi
                
    fi
else
    echo "User Pressed Cancel. with No File Selected."
fi
