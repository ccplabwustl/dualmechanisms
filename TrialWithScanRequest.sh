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
	curl -s -k -n https://${HOST}/data/projects/${PROJ}/subjects/${SUBJ}/experiments/${SUBJ}_${session}/scans?format=csv | cut -d, -f2,7 | grep tfMRI | grep -v 'SBRef\|Physio' > ${SUBJ}_${session}_trial.csv
popd
