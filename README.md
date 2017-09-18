# PhysioHelper
Purpose:
This tool will help build the UUIDs array and the runname array used in R01/Jo/physio/template_convert.m
if the option is chosen it will also cross compare its output array with you local _Info.log files to and remove the entries from the array that are not present locally

Requirements:
In order to use this tool:
you must be using a unix machine (Either: Mac/Linux) 
and have a .netrc file in your home directory that contains data for intraDB.

You may also want to have the files following the pattern ‘Physio_DATE_TIME_UUID_Info.log’
Stored in a directory in a directory on your computer.

You must be connected to the internet to use this.
