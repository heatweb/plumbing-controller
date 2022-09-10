#Promts the user for input storing into variable PASSWORD
read -p "Enter your password:" -e PASSWORD
read -p "Repeat your password:" -e PASSWORD2
if [ $PASSWORD -ne $PASSWORD2 ]; then         #(-ne) not equal command  
        echo "Invalid password, please start again."
        exit 0
else
        echo "Password is valid"
fi
