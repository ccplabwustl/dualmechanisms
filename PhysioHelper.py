# Purpose: To assist in generating the matlab matrix used in R01/Jo/physio/template_convert.m
# needed to process the Physio Files
# Author: Mitchell Jeffers
# Date: 8/2/17

import PhysioFunctions as PhyFun
import os
import glob

# get User Input
#TestValues:
# DIR = '/home/mitchell/Desktop/'
# SUBJ = '132017'
# SESS = 'baseline'
# PROJ = 'DMCC_Phase2'


#Get the User Input
DIR, PROJ, SUBJ, SESS = PhyFun.getUserInput()

ABV = SESS[:3].capitalize()

# trialIDDict Stores the Key scan number with the Value of the trial name
# fileNameDict stores the file name associated with the scan number
trialIDDict = {}
fileNameDict = {}

#Build the paths for the RawData and Preprocessed Data
RawDataDir = os.path.join(DIR, PROJ+'(HCP)', 'Raw_Data', SUBJ, SUBJ + '_' + SESS, 'physio_data')
PreProcDataDir = os.path.join(DIR, PROJ+'(HCP)', 'Preprocessed_Data', SUBJ, 'physio_data')

# Build The file Structure for the Data
if not os.path.exists(RawDataDir):
    os.makedirs(RawDataDir)

if not os.path.exists(PreProcDataDir):
    os.makedirs(PreProcDataDir)


# ########### IF YOU ARE USING DCM FILE ##########
# #Get the Correct file numbers that we need to download
# PhyFun.GetPhysioData(RawDataDir,PROJ, SUBJ, SESS)
#
# # open tmp.csv and store values into a dict where the Key is the the first column "tfMRI_Cuedts"
# with open(os.path.join(RawDataDir, 'tmp.csv'), mode='r') as infile:
#     reader = csv.reader(infile)
#     trialIDDict = {rows[0]: rows[1][-2:] for rows in reader}
# os.remove(os.path.join(RawDataDir, 'tmp.csv'))
#
#

# #Download DCM Files
# PhyFun.DownloadDCMFiles(RawDataDir, PROJ, SUBJ, SESS)
# #remove the file structure and build fileNameDict
# fileNameDict = PhyFun.BuildDCMDict(RawDataDir, SUBJ,SESS)

#Merge the two Dictionaries resulting in Key of trial names and Value of filenames
#trialFileDict = PhyFun.mergeDictionaries(trialIDDict, fileNameDict)
########## END DCM SPECIFIC CODE ############



########## IF YOU ARE USING LINKED_DATA LIKE  _Info.log ##########

#find the uuids and build a dict with key of scan numbers and value of uuid
trialFileDict = PhyFun.findUUIDs(RawDataDir, PROJ, SUBJ, SESS)


#after we have a scan numbers then find the file names with in the Raw_Data Folder that correspond to the UUIDs
for keys in trialFileDict.keys():
    os.chdir(RawDataDir)
    trialFileDict[keys] = glob.glob('Physio_*' + trialFileDict[keys] + '_Info.log')[0][:-9]
os.chdir(DIR)
########### END LINKED_DATA SPECIFIC CODE ##########

#Generalize the trial names
trialFileDict = PhyFun.DictCleanup(trialFileDict, ABV)

#build a String of the matrix for the matlab file
uuids, runnames = PhyFun.BuildMatrix(trialFileDict)


#Place it into the Matlab file
print "Copy the following lines into the matlab template file:\n\n"
print 'uuids = ' + (uuids)
print '\n\n'
print 'runnames = ' + (runnames)

