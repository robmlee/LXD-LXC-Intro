#! /usr/bin/env bash
##
##  Export LXD Instances. 
##
##  By RungBa
##  Created: 2021-10-18
##  Revised: 2025-02-13
##
#
logFile=`basename $0 | cut -d. -f1`.log

## Show help
if [ -z "$1" ] || [ "$1" == "-h" ]; then
   echo 
   echo "  *** Hint： "
   echo "  1. Export All: $0 -a"
   echo "  2. Export 1 or many: $0 ct1 ct2 "
   echo "  3. Show help: $0 -h"
   echo 
   exit 1
fi


## *************************************************
## Block for Function define
## *************************************************
## Function for creating backup directory for specific instance
CreBakDir(){
   local lxcName=$1
   
   echo "Creating backup folder ..."
   toPath=`pwd`/lxdct-bak/`date -I`-$lxcName
   
   ## Make sure the backup directory is existed
   if [ ! -d "$toPath" ]; then
      mkdir -p "$toPath" 2>&1 | tee -a $logFile
      printf "  -- Backup folder: $toPath ...\n"  2>&1 | tee -a $logFile
   else
      echo "  -- Already Exists Backup Folder [$toPath]!!!" | tee -a $logFile
   fi
}


## Function for checking instance existence
ChkInstName(){
   # check lxc instance
   local lxcName=$1
   echo "Instance [$lxcName] Checking ... " | tee -a $logFile

   lxcNameChk=`lxc ls | grep -w " $lxcName "`
   if [ -z "$lxcNameChk" ]; then
      echo "  -- Error: Lxc instance [$lxcName] NOT found!!!" | tee -a $logFile
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
      isStoped="1"
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
   #echo
   #echo "Done at" `date +"%Y-%m-%d %H:%M:%S"` | tee -a $logFile
   #echo | tee -a $logFile
}


## Function for export profiles
expProfile(){
   # check lxc instance
   local lxcName=$1
   local profileName=""
   
   echo "Exporting all the profiles that [$lxcName] is using ... " | tee -a $logFile
   
   for i in "${profileAllNames[@]}"
   do
	  profileName=$i
      #echo "Loop = "$i
      isFound=""
      #echo "  -- Exporting Profile: $i" | tee -a $logFile
      isFound=`lxc profile show $i | grep "/instances/$lxcName"`
      #echo "isFound = "$isFound
      if [ ! -z "$isFound" ]; then
	     if [ "$i" != "default" ]; then
		    profilesUsed[${#profilesUsed[@]}]="$profileName"
		    
            echo "  -- Profile found = [$profileName]"
            echo "  -- Removing profile [$profileName] from [$lxcName] before exporting ... " | tee -a $logFile
            lxc profile remove $lxcName $profileName  2>&1 | tee -a $logFile
			echo "  -- Done with Removing profile [$profileName] "
            echo "  -- Export profile [$profileName] for backup ..." | tee -a $logFile
            lxc profile show $profileName > $toPath/$profileName.yaml  2>&1 | tee -a $logFile
            echo "  -- Done with Exporting profile [$profileName]"
		    #return
		 else
		    ## We don't need to export the "default" profile. So just skip it.
		    echo "  -- Found profile [$profileName]. We don't need to export it!!!"
         fi
     fi
   done
}


## Function for adding profiles back to an Instance
## Ref: https://stackoverflow.com/questions/23605963/starting-for-loop-from-second-element-shell-script
## 
addProfilesBack(){
   local lxcName=$1
   local profileName=""

   echo "Add all the profiles back to [$lxcName] ... " | tee -a $logFile
   #for i in "${profilesUsed[@]:1}"   # start iterating from 2nd element
   for i in "${profilesUsed[@]}"    # start iterating from 1st element
   do
      #echo "Loop = "$i
      profileName=$i
	  echo "  -- ProfileName = [$profileName]" | tee -a $logFile
      if [ $profileName == "default" ]; then
	     echo "  -- Found profile [default], just skip adding it!!!"
         continue      
	  else
         #echo
	     echo "  -- Now Adding Profile [$profileName] back to [$lxcName] ... " | tee -a $logFile

         # Add profile back to instance
         lxc profile add $lxcName $profileName 2>&1 | tee -a $logFile
	  fi
   done
   echo "  -- Done!" | tee -a $logFile
}


## Function for executing export 
ExecExport(){
   local lxcName=$1
   #local hS2="  "
   #local hS3="   "

   #if [  ! -z "$profileName" ]; then
   #   echo "$hS2 Profile found = "$profileName
   #   echo "$hS2 => Temporarily removing profile $profileName from $lxcName before exporting ... " | tee -a $logFile
   #   lxc profile remove $lxcName $profileName  2>&1 | tee -a $logFile
   #   echo "$hS2 => Export profile: $profileName " | tee -a $logFile
   #   lxc profile show $profileName > $toPath/$profileName.yaml  2>&1 | tee -a $logFile
   #fi
   
   ## Exporting the instance
   echo "Now Exporting [$lxcName] to [$bakFile] " | tee -a $logFile
   echo "  -- Start at: "`date +"%Y-%m-%d %H:%M:%S"`" ..." | tee -a $logFile   
   lxc export $lxcName $toPath/$bakFile --compression bzip2 2>&1 | tee -a $logFile
   #lxc export $lxcName $toPath/$bakFile --optimized-storage 2>&1 | tee -a $logFile
   echo "  -- Done at: "`date +"%Y-%m-%d %H:%M:%S"`"!!!" | tee -a $logFile

   #date | tee -a $logFile
   #echo "  -- "`date +"%Y-%m-%d %H:%M:%S"` | tee -a $logFile
   #echo | tee -a $logFile
}


## Function for export Instances
ExpLoop(){
   local lxcName=""
   for i in "${lxdInstances[@]}"
   do
      #echo "Loop = "$i
	  lxcName=$i
      ## Set the backup file name.
      bakFile=$lxcName"_`date -I`.tar.bz2"
      #echo " bakFile= $bakFile" 
      
      ## Check the existence of a instance.
      ChkInstName $lxcName
      
	  ## 記錄 lxc container is running or not. Default is not running, ie isStoped="".
	  ##     Need to showdown the container if it is running.
      ChkInstStatus $lxcName

      ## Create Backup directory. '$toPath' will get the value here. 
	  CreBakDir $lxcName
	   
      ## Set default instance status tag. '0':STOPPED, '1':RUNNING.
      isStop="0"
      
      ## remove profiles before export
      expProfile $lxcName
   
      ## Begin to export the instance.
      ExecExport $lxcName
	  
      ## add profiles back before start the instance
      addProfilesBack $lxcName

	  ## Restore Lxd Instances Running Status
      restoreInstStatus $lxcName
   
      ## Log the datetime at end of this script
      #echo
      echo "Export Done at" `date +"%Y-%m-%d %H:%M:%S"` | tee -a $logFile
      echo | tee -a $logFile
   done
   printf "Exporting Lxd instances complete!!!\n\n" | tee -a $logFile
}

## *************************************************
## Main Process - Block for variables define
## *************************************************
## Define Variables
bakFile=""
## Set default instance status tag. '':STOPPED, '1':RUNNING.
isRunning=""

## 
declare -a profileAllNames=(`lxc profile ls -f csv | cut -d, -f1`)

## for keeping profile that is used by Instance
declare -a profilesUsed=()

## *************************************************
## Main Process
## *************************************************
if [ "$1" == "-a" ]; then
   #echo " \$# = $#, Export All lxd containers."
   
   ## Export all Version 1.
   #declare -a lxdInstances=(`lxc profile show default | grep "\/instances\/" | cut -d/ -f4`)
   
   ## Export all Version 2.
   declare -a lxdInstances=(`lxc ls -c n --format csv`)
   #echo $lxdInstances
else
   declare -a lxdInstances=("$@")
   #echo $lxdInstances
fi

echo | tee -a $logFile
echo "`date -I`: Begin to Export LXD Instances ---" | tee -a $logFile
echo | tee -a $logFile
#printf "\n*** `date -I` Begin to Export LXD instances\n" | tee -a $logFile
#printf "*** To folder: $toPath\n\n" | tee -a $logFile

## Export Lxd Instances
ExpLoop $lxdInstances

lxdInstances=""
profileAllNames=""
#echo | tee -a $logFile
