# Purpose: To assist in generating the matlab matrix used in R01/Jo/physio/template_convert.m
# needed to process the Physio Files
# Author: Mitchell Jeffers
# Date: 8/2/17

import PhysioFunctions as PhyFun


#TestValues:
# SUBJ = 'DMCC6671683'
# SESS = 'baseline'
# PROJ = 'DMCC_Phase2'


#Get the User Input
PROJ, SUBJ, SESS, COMP, DIR = PhyFun.getUserInput()

ABV = SESS[:3].capitalize()

#find the uuids and build a dict with key of scan numbers and value of uuid
trialScanDict = PhyFun.GetTrialInfo('.', PROJ, SUBJ, SESS)
print trialScanDict
scanUUIDDict = PhyFun.GetUUIDInfo('.', PROJ, SUBJ, SESS)
print scanUUIDDict
trialUUIDDict = PhyFun.mergeDictionaries(trialScanDict, scanUUIDDict)

#Generalize the trial names
trialFileDict = PhyFun.DictCleanup(trialUUIDDict, ABV)

if COMP == 'Yes':
    trialFileDict = PhyFun.CompareWithLocal(trialFileDict, DIR)

#build a String of the matrix for the matlab file
uuids, runnames = PhyFun.BuildMatrix(trialFileDict)


#Place it into the Matlab file
print "Copy the following lines into the matlab template file:\n\n"
print 'uuids = ' + (uuids)
print '\n\n'
print 'runnames = ' + (runnames)

