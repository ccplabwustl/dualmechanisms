#!/bin/bash
DOWNLOAD_LOCATION=/home/mitchell/Desktop/practice

HOST='intradb.humanconnectome.org'
PROJ='DMCC_Phase2'

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
pushd $DOWNLOAD_LOCATION
mkdir -p $SUBJ
pushd $SUBJ

for RESOURCE in $(IFS=% && curl -s -k -n https://intradb.humanconnectome.org/data/projects/${PROJ}/subjects/${SUBJ}/experiments/${SUBJ}_${session}/scans?format=csv | grep 'Physio' | cut -d, -f2,4,7; unset IFS); do
	echo -e "RESOURCE=${RESOURCE}"
	scan_num="$(echo ${RESOURCE} | cut -d, -f1)"
	scan_qa="$(echo ${RESOURCE} | cut -d, -f2)"
	scan_name="$(echo ${RESOURCE} | cut -d, -f3)"
	echo -e "\nDownloading scan ${scan_num}\tQUALITY ASSESSMENT:'${scan_qa}'\t${scan_name}'"
	printf "%-5s  %-35s  %-20s\n" "${scan_num}" "${scan_name}" "${scan_qa}"
	curl -k -n https://${HOST}/data/projects/${PROJ}/subjects/${SUBJ}/experiments/${SUBJ}_${session}/scans/${scan_num}/resources/secondary/files?format=zip > tmp.zip && unzip tmp.zip && rm tmp.zip
done
popd
popd

