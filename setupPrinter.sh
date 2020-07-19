#!/bin/bash
# ram
# rogue7.ram@gmail.com
# ver=0.4

# jul 5, 2020 / 20:15

# jul 10, 2020 / 07:26
# added lpstat -v, lpstat -a

# Jul 17, 2020 / 11:15
# added function for checking printer name

# Jul 18, 2020 / 01:34
# added function for port scanner

# jul 18, 2020 / 12:12
# added option to check server ip
# added option to specify port in the "scanprt" function

# jul 18, 2020  / 18:25
# made changes to nmap scan, it now outputs in a more useful format

# jul 19, 2020 / 13:52
# added option to find a usb printer connexted to the server
# not operational as yet.


CUPS=`service cups restart`
CUPSBKUP=`cp /etc/cups/printers.conf{,.setup}`
CUPSREVERT=`cp /etc/cups/printers.conf.setup /etc/cups/printers.conf`
#SHOWIP=`ifconfig | grep wlp2s0 -4 | grep inet | awk 'NR==1{print $2}'`
SHOWIP=`ifconfig | grep 'eth0\|em1' -4 | grep inet | awk 'NR==1{print $2}'`


#CHKUSB=`dmesg | grep -m 1 Bidirectional |  awk '{print $5}' | sed 's/://g' | sed 's/usb//g'`
#DMESGBU=`cat dmesg > /tmp/dmesg-`date +%d%m%Y`.log`
DMESGBU=`cat dmesg > /tmp/dmesg.log`
#CHKUSB=`dmesg | grep -m 1 sdb | awk '{print $5}' | sed 's/://g' | sed 's/usb//g'`
DMESGCLR=`dmesg -C`
CHKUSB=`dmesg | grep -m 1 sdb`




#echo "What do you want to name the printer?"
#echo "lex650, zeb3844, kyo4200..."
#echo "Where is the printer connected? Windows, Network or Server?"
#echo "What is the ip?"
#echo "What is the sharename?"
#echo "Send test print?"


chkname () {
	while true;
do
	echo -n "Enter printer name: "
	read NAME
	lpstat -v | awk '{print $3}' | sed 's/://g' | grep $NAME
	if [ "$?" !=  "0" ]
	then
		return
	else
		echo "This name is already being used."
		sleep 1
	fi

done
}


scanprt () {
	while true
do
	echo "Scan for Network  Windows printer or scan a specific port"
	echo -n ""W" for windows, "N" for network or "S" for a speific port: "
	read SCAN
	echo  ${SCAN^h}
	echo -n "Enter an ip on the network: "
	read IP
	if [ $SCAN == "w" ]
	then
		echo "Scanning for Windows printers. Please be patient: "
		echo
		nmap -v -p515 $IP | grep open -A1 -B4 | grep 'Nmap\|MAC' | paste -s -d",\n" | awk '{print $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}'
		echo
		echo -n "Enter "q" to quit: "
		read quit
		return
	elif [ $SCAN ==  "n" ]
	then
		echo "Scanning for Network printers. Please be patient; "
		echo
		nmap -v -p9100 $IP | grep open -A1 -B4 | grep 'Nmap\|MAC' | paste -s -d",\n" | awk '{print $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}'
		echo
		echo -n "Enter "q" to quit: "
		read quit
		return
	else [ $SCAN == "s" ] 
		echo -n "Enter an port number: "
		read PORT
		echo
		echo "Scanning for port $PORT and $IP. Please be patient"
		echo	
		nmap -v -p$PORT $IP | grep open -A1 -B4 | grep 'Nmap\|MAC' | paste -s -d",\n" | awk '{print $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}'
		echo "Enter "q" to quit: "
		read quit
		return
	fi
done
}




usbprt () {
i=0
#dmesg -C
#echo $DMESGBU
echo $DMESGCLR
#while [ $i -le 50000000 ]
while true;
do
        echo $CHKUSB
        if [ "$i" != 50000 -a "$?" == "0"  ]
        then
                echo "Printer $CHKUSB has been detected"
                echo "$?"
                sleep 1
                chkname
                break
                echo "Installing $CHKUSB as $NAME"
                lpadmin -p $NAME -v usb:/dev/usb/$CHKUSB -E
                echo "$NAME has been installed."
                sleep 1
        else
                echo "Printer not detected"
                echo $CHKUSB
                echo "$i"
                ((i=i+1))
                echo "$i"
                sleep 1
        fi
done
}



clrprtstop () {
	cat /etc/cups/printers.conf | grep Stopped -A1 



}












while true; do
	clear
        echo
        echo "#################"
        echo "# Printer Setup #"
        echo "#################"
        echo
#        echo "s. Server"
	echo "s. Scan for printers"
	echo "i. Print server ip"
	echo "w. Windows printer installation"
        echo "n. Network printer installation"
        echo "p. Print test page"
        echo "v. View installed printers"
	echo "a. View if printer is accepting print jobs"
	echo "j. View jobs not completed"
	echo "r. Restart print service"
	echo "c. Clear print queue" 
        echo "u. Undo installed printer"
	echo "q. Quit"
        echo
        echo
        echo -n "Please make a choice: "
        read CHOICE
        echo


case $CHOICE in
        "s" | "S")
		clear
                scanprt
                ;;
	"i" | "I")
		clear
		echo $SHOWIP
		echo
		echo -n "Press "q" to quit: "
		read quit
		;;
        "w" | "W")
		clear
                echo -n "What is the ip: "
                read IP
		echo $IP
                echo -n "What is the sharename: "
                read SHARE
		echo $SHARE
                chkname
		echo "Adding printer: "
                echo $CUPSBKUP
		sleep 1
                lpadmin -p "$NAME" -v lpd://"$IP"/"$SHARE" -E
                sleep 1
                echo "Restarting cups"
                echo $CUPS
                sleep 2
                ;;
        "n" | "N")
                clear
		echo -n "What is the ip: "
                read IP
		echo $IP
                chkname
		echo "Adding printer :"
                echo $CUPSBKUP
                sleep 1
                lpadmin -p "$NAME" -v socket://"$IP":9100 -E
		;;
        "p" | "P")
		echo -n "Enter printer name: "
		read NAME
                echo "Printing the hosts file to $NAME"
                lpr -P $NAME /etc/hosts
		echo "Test print sent to $NAME"
                sleep 2
                ;;
        "v" | "V")
		echo "Press "q" to quit"
                lpstat -v | less
                ;;
	"a" | "A")
		echo "Press "q" to quit"
		lpstat -a | less
		;;
	"j" | "J")
		echo "Press "q" to quit"
		lpstat -W not-completed | less
		;;
	"r" | "R")
		clear
		echo "Restarting print service"
		$CUPS
		sleep 1
		echo "Service has been restarted"
		sleep 1
		;;
	"c" | "C")
		clear
		echo "Clearing print queue"
		cancel -a
		echo "Print queue cleared"
		sleep 1
		;;
        "u" | "U")
		clear
		echo "Reverting back"
                echo $CUPSREVERT
                $CUPS
		sleep 1
		echo "Revert complete"
		sleep 1
                ;;
        "q" | "Q")
                break
                ;;
                *)
                echo "Invalid choice"
                ;;
esac


done
