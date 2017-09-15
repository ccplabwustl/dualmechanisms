#!/bin/bash

HOST='intradb.humanconnectome.org'
PROJ='DMCC_Phase2'
DOWNLOAD_LOCATION=~

while getopts s:e:p:d: option
do
 case "${option}"
 in
 s) SUBJ=${OPTARG};;
 e) session=${OPTARG};;
 p) PROJ=${OPTARG};;
 d) DOWNLOAD_LOCATION=${OPTARG};;
 esac
done

#read -p "ENTER SUBJECT: " SUBJ; echo $SUBJ
#read -p "ENTER SESSION: " session; echo $session

pushd ${DOWNLOAD_LOCATION}
	curl -s -k -n https://${HOST}/data/projects/${PROJ}/subjects/${SUBJ}/experiments/${SUBJ}_${session}/scans/ALL/resources/LINKED_DATA/files?format=csv | cut -d, -f3 | cut -d'/' -f6,11 | tr '/' ',' | cut -d_ -f1,3,4,5 | grep -v '.wav\|.txt\|.edat2\|edf' | awk -F, '!seen[$1]++' | grep -v URI | cut -d. -f1 > ${SUBJ}_${session}_UUIDS.csv 
popd
