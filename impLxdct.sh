#! /usr/bin/env bash
##
##  Import LXD Instances. 
##
##  By RungBa
##  Created: 2021-10-18
##  Revised: 2025-02-14
##
#
logFile=`basename $0 | cut -d. -f1`.log

## Show help
if [ -z "$1" ] || [ "$1" == "-h" ]; then
   echo 
   echo " **** Hint： $0 [back file 1] [[back file 2] ..."
   echo "     Ex 1.： $0 lxdct1-2021-10-10.tar.bz2 "
   echo "     Ex 2.： $0 lxdct1.tar.bz2  lxdct2.tar.bz2 "
   echo " Show help： $0 -h"
   exit 1
fi


## *************************************************
## Block for Function define
## *************************************************
## Function for checking instance existence
ChkInstName(){
   # check lxc instance
   local lxcName=$1
   echo "Instance [$lxcName] Checking ... " | tee -a $logFile
   
   lxcNameChk=`lxc ls | grep -w " $lxcName "`
   if [ -z "$lxcNameChk" ]; then
      echo "  - Instance [$lxcName] not found. OK to Import ..." | tee -a $logFile
      echo | tee -a $logFile
      return 0
   else
      hasError="1"
      echo "  - Instance [$lxcName] is already in the LXD system!!!" | tee -a $logFile
      echo "    Please Delete it Manually before importing." | tee -a $logFile
      echo "    " | tee -a $logFile
      return 1
   fi
}

## Function for checking existence of bakFile
ChkBakFile(){
   echo "File [$bakFile] Checking ... " | tee -a $logFile
   #echo "bakPath = "$bakPath
   #echo "bakFile = "$toPath/$bakFile
   #bakFile=$bakPath/$bakFile
   if [ -s "$bakPath/$bakFile" ]; then
      # if the FILE exists and has nonzero size.
      echo "  - File [$bakPath/$bakFile] is OK ... " | tee -a $logFile
      return 0
   else
      echo "  - File [$bakPath/$bakFile] is NOT Found!!!  " | tee -a $logFile
      return 1
   fi
}


## Function for executing import 
ExecImport(){
   local lxcName=$1
   local ret=0
   
   #echo "Begin to import [$lxcName] ..." | tee -a $logFile

   ## 
   echo "Importing [$lxcName] ..." | tee -a $logFile
   lxc import $bakPath/$bakFile 2>&1 | tee -a $logFile
   if [[ "$?" -ne "0" ]]; then
      echo "  - Importing $lxcName with Error code: #?" | tee -a $logFile
      hasError="1"
      #exit 1
   fi
   #date | tee -a $logFile
   #echo | tee -a $logFile
}


## Function for import Instances
ExpLoop(){
   echo | tee -a $logFile
   echo "Begin to Import LXD/LXC Instances ..." | tee -a $logFile
   echo "  -- `date +"%Y-%m-%d %H:%M:%S"`" | tee -a $logFile


   for i in "${argInstances[@]}"
   do
      #echo "Loop = "$i
	  
	  ## --------------------------------
      ## Set the importing file name.
      #bakFile=$i
      bakFile=`basename $i`
      bakPath=`dirname $i`

      ## Check existence of bakFile
      ChkBakFile
      ret=$?  ## get the return of ChkBakFile
      #echo " ret= "$ret
      ## 
      if [[ "$ret" -ne "0" ]]; then
	     ## If bakfile NO good, then skip.
	     continue
      fi
	  
	  ## --------------------------------
      ## Set the instance name.
	  lxcName=`echo $i | cut -d"_" -f1`
      #echo " lxcName: "$lxcName
      
      ## Set default instance status tag. '0':STOPPED, '1':RUNNING.
      #isStop="0"
      
      ## Check existence of instance
      ChkInstName $lxcName
      ret=$?  ## get the return status of ChkInstName
      #echo " ret= "$ret
   
      ## 
      if [[ "$ret" -eq "0" ]]; then
         ## Begin to import the instance.
         ExecImport $i
	  else
	     :  # pass
	  fi
   done

   ## Log the datetime at end of this script
   echo
   echo "  - Done at" `date +"%Y-%m-%d %H:%M:%S"` | tee -a $logFile
   #echo | tee -a $logFile
   if [ "$hasError" == "0" ]; then
      printf "Done with no error.\n" | tee -a $logFile
   else
      echo "---------- Done with ERROR !!! ----------"
      printf "  - Error(s) logged in $logFile !!!\n" | tee -a $logFile
   fi
   echo | tee -a $logFile
}

## *************************************************
## Block for variables define
## *************************************************
## Define Variables
#lxcName=$1
#toPath="."
hasError="0"


## *************************************************
## Main Process
## *************************************************
declare -a argInstances=("$@")
ExpLoop $argInstances
