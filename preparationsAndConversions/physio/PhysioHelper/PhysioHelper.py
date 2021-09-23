# Purpose: To assist in generating the matlab matrix used in R01/Jo/physio/template_convert.m
# needed to process the Physio Files
# Author: Mitchell Jeffers
# Date: 8/2/17

import PhysioFunctions as PhyFun


#TestValues:
#SUBJ = 'DMCC6671683'
#SESS = 'baseline'
#PROJ = 'DMCC_Phase2'
#REST = True
#COMP = 'No'


#Get the User Input
PROJ, SUBJ, SESS, COMP, DIR, REST = PhyFun.getUserInput()

ABV = SESS[:3].capitalize()
PhyFun.ChangeWorkingDir()
#find the uuids and build a dict with key of scan numbers and value of uuid
trialScanDict = PhyFun.GetTrialInfo(PROJ, SUBJ, SESS)

scanUUIDDict = PhyFun.GetUUIDInfo(PROJ, SUBJ, SESS)

trialUUIDDict = PhyFun.mergeDictionaries(trialScanDict, scanUUIDDict)

#Generalize the trial names
trialFileDict = PhyFun.DictCleanup(trialUUIDDict, ABV)

if COMP == 'Yes':
    trialFileDict = PhyFun.CompareWithLocal(trialFileDict, DIR)

#build a String of the matrix for the matlab file
uuids, runnames = PhyFun.BuildMatrix(trialFileDict)

#Place it into the Matlab file

if uuids != 'no value':
    print "Copy the following lines into the matlab template file:\n\n"
    print 'uuids = ' + (uuids)
    print '\n\n'
    print 'runnames = ' + (runnames)

else:
    print 'The generated arrays are empty '
    print 'please verify you\'ve entered all parameters correctly'

if REST:

    uuids_rest, runnames_rest = PhyFun.BuildMatrixRest(trialFileDict)

    if uuids_rest != 'no value':
        print "Copy the following lines into the matlab template file:\n\n"
        print 'uuids = ' + (uuids_rest)
        print '\n\n'
        print 'runnames = ' + (runnames_rest)

    else:
        print 'The generated arrays are empty '
        print 'please verify you\'ve entered all parameters correctly'
