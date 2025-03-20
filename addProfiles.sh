#! /usr/bin/env bash
##
##  Setting and adding new profiles to a LXD container. 
##  
##  By RungBa
##  Created: 2025-02-11
##  Revised: 2025-02-13
##
#
logFile=`basename $0 | cut -d. -f1`.log

## Show help
if [ -z "$1" ]; then
   echo 
   echo "  *** For Container： $0 [lxd container name] routed_[192.168.1.10].yaml "
   echo "  *** For LXD VM   ： $0 [lxd container name] routed-vm_[192.168.1.10].yaml "
   echo 
   exit 1
fi


## *************************************************
## Block for Function define
## *************************************************
## Function for checking instance name
ChkInstName(){
   ## check lxc instance
   local lxcName=$1
   echo "Instance [$lxcName] Checking ... " | tee -a $logFile
    
   lxcNameChk=`lxc ls | grep -w " $lxcName "`
   if [ -z "$lxcNameChk" ]; then
      echo "  -- Error: Lxc instance [$lxcName] not found!!!" | tee -a $logFile
      echo | tee -a $logFile
      exit 1
   else
      echo "  -- [$lxcName] is OK!" | tee -a $logFile
   fi
}

## Function for checking instance is running or not
ChkInstStatus(){
   ## check lxc instance
   local lxcName=$1
   echo "Instance [$lxcName] Running Status Checking ... " | tee -a $logFile
    
   ## shutdown the instance if it is running 
   isRunning=`lxc ls | grep -w " $lxcName " | grep 'RUNNING'`
   if [ -n "${isRunning}" ]; then
      echo "  -- The instance [$lxcName] is running!" | tee -a $logFile
      echo "  -- Shutting down [$lxcName] ... " | tee -a $logFile
      lxc stop $lxcName 2>&1 | tee -a $logFile
      #isStoped="1"
      echo "  -- [$lxcName] is DOWN now!" | tee -a $logFile
   else
      echo "  -- [$lxcName] is NOT running!" | tee -a $logFile
   fi
}

## Function for Restoring Lxd Instances Running Status
restoreInstStatus(){
   local lxcName=$1

   ## Bring back online
   if [ ! -z "$isRunning" ]; then
      echo "Bring the [$lxcName] back ONLINE ..." | tee -a $logFile
      lxc start $lxcName 2>&1 | tee -a $logFile
      echo "The [$lxcName] is back ONLINE. " | tee -a $logFile
   else
      echo "The [$lxcName] was NOT RUNNING so let it stay OFFLINE. " | tee -a $logFile
   fi
   
   ## Log the datetime at end of this script
   echo
   echo "Done at" `date +"%Y-%m-%d %H:%M:%S"` | tee -a $logFile
   echo | tee -a $logFile
}


## Function for checking yaml file
ChkYamlFile(){
   newP_nic=""
   oldP_nic=""
   echo "Yaml File Checking ... " | tee -a $logFile
   
   ## check yamlFile
   if [ ! -f "$yamlFile" ]; then
      echo "  -- Error: File [$yamlFile] not found!!!" | tee -a $logFile
      echo | tee -a $logFile
      exit 1
   else
      echo "  -- [$yamlFile] is OK!" | tee -a $logFile
   fi

   ## (2025-01-22) in case in a new host, might need to change the parent of eth0
   ## ref: https://serverfault.com/a/845116
   echo "Yaml File NIC Checking ... " | tee -a $logFile
   newP_nic=`ip -br l | awk '$1 !~ "lo|vir|wl|veth" { print $1}' | grep -E 'enp|eth'`
   oldP_nic=`cat $yamlFile | grep 'parent' | cut -d' ' -f6`
   echo "  -- Host NIC: [$newP_nic]" | tee -a $logFile
   echo "  -- Profile NIC: [$oldP_nic]" | tee -a $logFile
  
   #if [[ (-z "$newP_nic") || (-z "$oldP_nic") ]]; then
   if [[ (! -z "$newP_nic") && (! -z "$oldP_nic") ]]; then
      if [[ ("$newP_nic" == "$oldP_nic") ]]; then
	     echo "  -- [$yamlFile] NIC is OK!" | tee -a $logFile
	  else
	     sed -i "s/${oldP_nic}/${newP_nic}/g" $yamlFile
         echo "  -- [$yamlFile] NIC has been adjusted!" | tee -a $logFile
	  fi
   else 
      if [[ (-z "$oldP_nic") ]]; then
	     echo "  -- [$yamlFile] has no NIC config setting!!!" | tee -a $logFile
	  else
         echo "  -- Warning: Host NIC NOT Found!!!" | tee -a $logFile
	  fi
   fi
}


## Define function SetNewProfile
SetNewProfile() {
   local lxcName=$1
   #echo "==> Setting New Profile for $lxcName ... " | tee -a $logFile
   
   ## check the existence of profile
   profileFound=`lxc profile ls -f csv | cut -d, -f1 | grep "\<$profileName\>"`
   if [ -z "$profileFound" ]; then
      ## create new profile
      echo "  -- Creating Profile Name [$profileName] to LXD ..." | tee -a $logFile
      lxc profile create $profileName 2>&1 | tee -a $logFile
	  
      ## load new setting
      echo "  -- Loading new config setting to [$profileName] ..." | tee -a $logFile
      cat $yamlFile | lxc profile edit $profileName 2>&1 | tee -a $logFile
   else
      ## ask for override
	  ans=""
      read -p "  -- Profile [$profileName] already exists in LXD! Override it? [N]/y: " ans
      ans=${ans:-N}  # Set default ans to N

      #echo "  -- Profile [$profileName] already exists in LXD!" >> $logFile
      if [[ "$ans" =~ ^(Y|y)$ ]]; then
         ## load new setting
    	 echo "  -- Loading new config setting for [$profileName] ..." | tee -a $logFile
    	 cat $yamlFile | lxc profile edit $profileName 2>&1 | tee -a $logFile
	  else
         ## log user deny to load new setting 
    	 echo "  -- User DENY to load new config setting for [$profileName] ..." | tee -a $logFile
      fi
   fi
   
   ## check whether the instance is already using the profile
   lxcIsUsingThisProfile=`lxc profile show $profileName | grep "\<instances/$lxcName\>"`
   #echo "lxcIsUsingThisProfile = $lxcIsUsingThisProfile"
   
   ## Add new profile for instance
   if [ -z "$lxcIsUsingThisProfile" ]; then
      echo
      lxc profile add $lxcName $profileName 2>&1 | tee -a $logFile
   else
      echo "  -- The [$lxcName] already had the profile [$profileName]!" | tee -a $logFile
   fi
}

  
## Function for adding profiles to an Instance
## Ref: https://stackoverflow.com/questions/23605963/starting-for-loop-from-second-element-shell-script
## 
AddProfileLoop(){
   local lxcName=$1

   #for i in "${yamlMultiFiles[@]}"    # start iterating from 1st element
   for i in "${yamlMultiFiles[@]:1}"   # start iterating from 2nd element
   do
      #echo "Loop = "$i
      yamlFile=$i
      
      profileName=`cat $yamlFile | grep '^name:' | cut -d' ' -f2`
      echo
      echo "ProfileName = [$profileName]" | tee -a $logFile
	  echo "Now Adding Profile [$yamlFile] to [$lxcName] ... " | tee -a $logFile

      ## Check the existence of yaml file.
      ChkYamlFile $i
      
      ## Main function to process.
      SetNewProfile "$lxcName"      
   done
}


## *************************************************
## Main Process - Block for variables define
## *************************************************
## Define Variables
#toPath="$HOME/lxdOdooEnv-test"
toPath=`pwd`

## 
lxcName=$1
#yamlFile=$2
declare -a yamlMultiFiles=("$@")

## Set default instance status tag. '':STOPPED, '1':RUNNING.
isRunning=""
#isStoped=""

## 
echo
echo "Begin to add profile(s) to [$lxcName] ......" | tee -a $logFile
#echo
echo "LxcName = [$lxcName]" | tee -a $logFile
echo

## *************************************************
## Main Process
## *************************************************
## 記錄 lxc container is valid or not.
ChkInstName $lxcName

## 記錄 lxc container is running or not. Default is not running, ie isStoped="".
##     Need to showdown the container if it is running.
ChkInstStatus $lxcName

## Add prfiles to Lxd Instances
AddProfileLoop $lxcName

## Restore Lxd Instances Running Status
restoreInstStatus $lxcName