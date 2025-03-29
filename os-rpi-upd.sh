#!/bin/bash
logFile=`basename $0 | cut -d. -f1`.log

echo | tee -a $logFile
uname -a | tee -a $logFile
echo | tee -a $logFile
sudo apt update | tee -a $logFile;sudo apt full-upgrade -y | tee -a $logFile
sudo apt autoremove -y | tee -a $logFile; sudo apt autoclean | tee -a $logFile

# check bootloader version 
sudo rpi-eeprom-update | tee -a $logFile

# update kernel and firmware
sudo rpi-update | tee -a $logFile

# check again after update bootloader
sudo rpi-eeprom-update | tee -a $logFile

echo | tee -a $logFile
uname -a | tee -a $logFile
date +"%Y-%m-%d %H:%M:%S" | tee -a $logFile
echo | tee -a $logFile
