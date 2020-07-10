#!/bin/bash

# ram
# ver=0.2
# jul 5, 2020 / 20:15

# jul 10, 2020 / 07:26
# added lpstat -v, lpstat -a


CUPS=`service cups restart`
CUPSBKUP=`cp /etc/cups/printers.conf{,.setup}`
#echo "What do you want to name the printer?"
#echo "lex650, zeb3844, kyo4200..."
#echo "Where is the printer connected? Windows, Network or Server?"
#echo "What is the ip?"
#echo "What is the sharename?"

#echo "Send test print?"



while true; do
        echo
        echo "#################"
        echo "# Printer Setup #"
        echo "#################"
        echo
#        echo "s. Server"
        echo "w. Windows"
        echo "n. Network"
        echo "p. Print test page"
        echo "v. View installed printers"
	echo "a. View if printer is accepting print jobs"
	echo "j. View jobs not completed"
        echo "u. Undo installed printer"
	echo "q. Quit"
        echo
        echo
        echo -n "Please make a choice: "
        read CHOICE
        echo


case $CHOICE in
        "s" | "S")
                read -p "What will you name it:"
                echo $NAME
                echo "Have the customer power off the printer."
                read -p "Type 'o' when the printer is off: "
                echo $o
                echo "Now power it up"
                # do stuff with dmesg
                echo "Adding printer"
                echo $CUPSBKUP
                lpadmin -p $NAME usb:/dev/usb/lp0 -E
                echo "Restartting cups"
                echo $CUPS
                sleep 3
                ;;
        "w" | "W")
                read -p "What is the ip:"
                echo $IP
                read -p "What is the sharename:"
                echo $SHARE
                read -p "What will you name the printer:"
                echo $NAME
                echo "Adding printer:"
                echo $CUPSBKUP
                lpadmin -p $NAME lpd://$IP/$SHARE -E
                echo "Restarting cups"
                echo $CUPS
                sleep 3
                ;;
        "n" | "N")
                read -p "What is the ip:"
                echo $IP
                read -p "What will you name the printer:"
                $NAME
                echo "Adding printer:"
                echo $CUPSBKUP
                lpadmin -p $NAME socket://$IP:9100 -E
                sleep 3
                ;;
        "p" | "P")
                echo "Printing the hosts file to $NAME"
                lpadmin -p $NAME /etc/hosts
                sleep 3
                ;;
        "v" | "V")
                lpstat -v
		sleep 3
                ;;
	"a" | "A")
		echo "Show print queue:"
		lpstat -a
		sleep 3
		;;
	"j" | "J")
		echo "Jobs not completed:"
		lpstat -W not-completed
		sleep 3
		;;
        "u" | "U")
                cp $CUPSBKUP /etc/cups/printers.conf
                echo $CUPS
                ;;
        "q" | "Q")
                break
                ;;
                *)
                echo "Invalid choise"
                ;;
esac


done
