#!/bin/bash
#This script will find all files in a given path with the .wav extention and create a subfolder called "Clean". 
#It will then pass the audio files through a lowpass filter and normalize them
PATH=$PATH:/usr/local/bin #if you have issues loading sox try running 'which sox' in the terminal and editing the this pathway to match 
command -v sox >/dev/null 2>&1 || { echo >&2 "This Program requires sox but it's not installed.  Aborting."; exit 1; }

if [ ! -d "$1" ]; then
	echo "error Directory Does not Exist: $1"
	exit
fi 

pushd $1
echo "Now Noise Cancelling:"
Files=$(ls *.wav)

if [ ! -d "${1}/Clean" ]; then
    
    mkdir Clean
    cp $Files Clean/

    pushd Clean

    for file in ${Files}; do
        #sox noisered 
        #sox $file -n noiseprof noise.prof
        #sox  -q $file tmp.wav noisered noise.prof 0.21
        #mv tmp.wav $file

        sox $file tmp.wav lowpass 500 lowpass 500
        sox --norm tmp.wav $file  
    done
    
    rm tmp.wav
    
    popd
else
    echo "Clean Directory already exists"
    echo "Skipping Cleaning"
    exit
fi
