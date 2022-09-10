#Promts the user for input storing into variable PASSWORD
read -p "Enter your password:" -e PASSWORD -s
read -p "Repeat your password:" -e PASSWORD2 -s
if [ $PASSWORD -ne $PASSWORD2 ]; then         #(-ne) not equal command  
        echo "Passwords do not match, please start again."
        exit 0
else
        echo "Password is valid"
fi
