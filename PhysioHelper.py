# Purpose: To assist in generating the matlab matrix needed to process the Physio Files
# Author: Mitchell Jeffers
# Date: 8/2/17

import PhysioFunctions as PhyFun
import os
import shutil
import csv
# get User Input

#TestValues:
# DIR = '/home/mitchell/Desktop/'
# SUBJ = '132017'
# SESS = 'baseline'
# PROJ = 'DMCC_Phase2'

DIR = raw_input("Enter the directory for the download\n(usually your Desktop): ")
PROJ = raw_input('Enter DMCC_Phase2 or DMCC Phase3: ')
SUBJ = str(input('Enter the subject number: '))
SESS = raw_input('Enter the session: ')



ABV = SESS[:3].capitalize()
trialIDDict = {}
fileNameDict = {}

RawDataDir = os.path.join(DIR,PROJ,'Raw_Data', SUBJ, SUBJ+'_'+SESS,'physio_data')
PreProcDataDir = os.path.join(DIR,PROJ,'Preprocessed_Data', SUBJ, 'physio_data')

#Build The file Structure for the Data
if not os.path.exists(RawDataDir):
    os.makedirs(RawDataDir)

if not os.path.exists(PreProcDataDir):
    os.makedirs(PreProcDataDir)

#Get the Correct file numbers that we need to download
PhyFun.GetPhysioData(RawDataDir,PROJ, SUBJ, SESS)

#Download those Files
PhyFun.DownloadPhysioFiles(RawDataDir, PROJ, SUBJ, SESS)

#open tmp.csv and store values into a dict
with open(os.path.join(RawDataDir,'tmp.csv'), mode='r') as infile:
    reader = csv.reader(infile)
    trialIDDict = {rows[0]: rows[1][-2:] for rows in reader}
os.remove(os.path.join(RawDataDir,'tmp.csv'))

#remove all rest and StroopTest physio files
trialIDDict = {key: value for key, value in trialIDDict.items()
             if ('Rest' not in key and 'Test' not in key)}

#Generalize Keys to make names more universal,
for key, value in trialIDDict.items():
    trialIDDict[key[6:].replace(ABV, '').replace('_PhysioLog', '')] = trialIDDict.pop(key)

#Find Files and place in a dictionary with their scan number
#Make a dictionary With a Key of scan Number and a value of Filename
#move the files to the parent directory for the matlab script
scansPath = os.path.join(RawDataDir, SUBJ+'_'+SESS,'scans')
for directory in os.listdir(scansPath):
    for root, dir, files in os.walk(os.path.join(scansPath,directory)):
        for name in files:
            fileNameDict[directory[:2]] = os.path.splitext(name)[0]
            shutil.copy(os.path.join(root, name), os.path.join(RawDataDir, name))
shutil.rmtree(os.path.join(RawDataDir, SUBJ+'_'+SESS))


#Merge the two Dictionaries resulting in Key of trial names and Value of filenames
dictMerge = PhyFun.mergeDictionaries(trialIDDict, fileNameDict)


#build a String of the matrix for the matlab file
uuids, runnames = PhyFun.BuildMatrix(dictMerge)

#Place it into the Matlab file
print "Copy the following lines into the matlab template file:\n\n"
print 'uuids = ' + (uuids)
print 'runnames = ' + (runnames)

