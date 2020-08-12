#!/bin/bash
# ram
# rogue7.ram@gmail.com
# ver=0.5
#setupPrinter.sh.dev17.0.3e

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
# added option to find a usb printer connected to the server
# not operational as yet.
# jul 20, 2020 / 22:06
# got usb printer connected to the server working

# jul 26, 2020 / 15:55
# fixed various bugs
# made an expermintal change to the UI

# jul 30, 2020 ? 18:23
# fixed checkname
# fixed editing of printers.conf


#################
### variables ###
#################
CUPS=`service cups restart`
CUPSBKUP=`cp /etc/cups/printers.conf{,.setup}`
CUPSREVERT=`cp /etc/cups/printers.conf.setup /etc/cups/printers.conf`
PCONF="/etc/cups/printers.conf"
SHOWIP=`ifconfig | grep 'eth0\|em1\|wlan0' -4 | grep inet | awk 'NR==1{print $2}'`
CHKUSB=`dmesg | grep -m 1 Bidirectional | awk '{print $5}' | sed -e 's/://; s/usb//g'`
DMESGBU=`yes | cp /var/log/dmesg /tmp/dmesg-old.setup`
DMESGCLR=`dmesg -C`
PCONFBU="/tmp/printers.conf"
CONFRES=`yes | cp -v /tmp/printers.conf /etc/cups/printers.conf`

##############################################################
### checks that the printer name is not already being used ###
##############################################################

chkname () {
while true;
do
	echo -n "Enter printer name: "
	read NAME
	checkName=`lpstat -v | awk '{print $3}' | grep ^$NAME\: | wc -l`
	if [ $checkName -gt 0 ]
	then
		echo "Printer name is already being used."
	else
		return
	fi
done
}



###########################################################################
### port scanner for port 515, 9100 and another for chosing another port ###
###########################################################################
scanprt () {
clear
echo
echo "+---------------------------------+"
echo "| SERVER IP: $SHOWIP		 "
echo "+---------------------------------+"
echo
echo -n "[N]etwork, [W]indows or [S]pecific port: "
read SCAN
echo
echo "Scan an ip, 192.168.0.1 or range 192.168.0.*"
echo
echo -n "IP: "
read IP
case $SCAN in
	"w"| "W")
		echo "Scanning for open ports. Please be patient: "
		echo
		nmap -p515 $IP | grep open -A1 -B4 | grep 'Nmap\|MAC' | paste -s -d",\n" | awk '{print $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}'
		echo
		echo -n "Enter "q" to quit: "
		read quit
		return
		;;
	"n" | "N")
		echo "Scanning for open ports. Please be patient: "
		echo
		nmap -p9100 $IP | grep open -A1 -B4 | grep 'Nmap\|MAC' | paste -s -d",\n" | awk '{print $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}'
		echo
		echo -n "Enter "q" to quit: "
		read quit
		return
		;;
	"s" | "S")
		echo -n "Enter an port number: "
		read PORT
		echo
		echo "Scanning for open port $PORT on $IP. Please be patient:"
		echo	
		nmap -p$PORT $IP | grep open -A1 -B4 | grep 'Nmap\|MAC' | paste -s -d",\n" | awk '{print $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15}'
		echo "Enter "q" to quit: "
		read quit
		return
		;;
		*)
		echo "Invalid choice. Try again."
		sleep 1
		;;
esac
}


#############################################################
### suppost to find usb printer and install on the server ###
#############################################################
usbprt () {
i=0
echo $DMESGBU
echo $DMESGCLR
sleep 1
while true;
do
        $CHKUSB
        if [ $? -gt 0 || $i -eq 10 ];
        then
                echo "Printer $CHKUSB has been detected"
                chkname
                echo "Installing $CHKUSB as $NAME"
		lpadmin -p $NAME -v usb:/dev/usb/$CHKUSB -E
                echo "$NAME has been installed."
		sleep 1
		return
        else
                echo "Printer not detected"
                echo "$i"
                ((i=i+1))
		sleep 1
                if [ $i -eq 30 ]
		then
			echo "Printer not detected. Try again."
			return
		else
			echo
		fi
        fi
done
}



notComplete () {
while true
do
clear
echo
lpstat -l | grep queued | awk '{print $3}' | uniq -c
echo
echo '[R] Restart cups [C] Clear print queue [Q] Quit'
echo -n "Choice: "
read choice
case $choice in
	"r" | "R")
		echo 'Backing up printers.conf'
		$CUPSBKUP
		sleep 1
		echo 'Removing stopped messages'
		sleep 1
		sed 's/StateMessage//;s/Stopped/Idle/;s/stop-printer/retry-job/;s/OpPolicy default//;s/Default//;/^[[:space:]]*$/d' <$PCONF >$PCONFBU && yes | mv $PCONFBU $PCONF
		#$MSGDEL
		echo 'Restarting cups'
		$CUPS
		sleep 2
		;;
	"c" | "C")
		echo "Canceling all jobs."
		cancel -a
		sleep 1
		;;
	"q" | "Q")
		return
		;;
	*)
		echo 'Invalid entry. Try again.'
		sleep 1
		;;
esac
done
}


#################
### main menu ###
#################
while true; do
	clear
	echo
        echo "     +---------------------------------------------+"
	echo "     |                 Setup Printer               |"
	echo "     +---------------------------------------------+"
	echo "     |    [W] Windows printer                      |"
	echo "     |    [N] Network Printer                      |"
	echo "     |    [U] USB printer to the server            |"
	echo "     |                                             |"
	echo "     +---------------------------------------------+"
	echo "     |              Troubleshoot Printer           |"
	echo "     +---------------------------------------------+"
	echo "     |    [S] Scan for open printer ports          |"
	echo "     |    [P] Print test page                      |"
	echo "     |                                             |"
	echo "     |    [V] View installed printers              |"
	echo "     |    [J] Jobs not completed                   |"
	echo "     |                                             |"
	echo "     |    [Q] QUIT                                 |"
	echo "     +---------------------------------------------+"
	echo 
	echo -n "  		Please make a choice: "
        read CHOICE
        echo


#################
### main body ###
#################
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
                sleep 1
                ;;
        "n" | "N")
                clear
		echo -n "What is the ip: "
		read IP
		echo $IP
                chkname
		echo "Adding printer $NAME:"
                echo $CUPSBKUP
                sleep 1
                lpadmin -p "$NAME" -v socket://"$IP":9100 -E
		;;
	"u" | "U")
		usbprt
		;;
        "p" | "P")
		clear
		echo -n "Enter printer name: "
		read NAME
                echo "Printing the hosts file to $NAME"
                lpr -P $NAME /etc/hosts
		echo "Test print sent to $NAME"
                sleep 2
                ;;
        "v" | "V")
		clear
		echo "Press "q" to quit"
                lpstat -v | less
                ;;
	"j" | "J")
		echo
		notComplete
		;;
        "q" | "Q")
                break
                ;;
                *)
                echo "Invalid choice"
                ;;
esac


done
