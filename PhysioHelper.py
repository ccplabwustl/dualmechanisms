# Purpose: To assist in generating the matlab matrix needed to process the Physio Files
# Author: Mitchell Jeffers
# Date: 8/2/17

import PhysioFunctions as PhyFun
import os
import shutil
import csv
# get User Input

#TestValues:
DIR = '/home/mitchell/Desktop/DMCC_Phase2/Raw_Data'
SUBJ = '132017'
SESS = 'baseline'

# DIR = raw_input("ENTER THE DIRECTORY FOR THE DOWNLOAD: ")
# SUBJ = str(input('ENTER SUBJECT NUMBER: '))
# SESS = raw_input('ENTER SESSION: ')
PROJ = 'DMCC_Phase2'
ABV = SESS[:3].capitalize()
trialIDDict = {}
fileNameDict = {}
#OriginalTemplateConverter = '/home/mitchell/R01/Jo/physio/template_convert.m'
#OriginalTemplateConverter = '/scratch1/MitchJeffers/R01/Jo/physio/template_conterter.m'
FullDIR = os.path.join(DIR,SUBJ,SUBJ+'_'+SESS,'physio_data')
if not os.path.exists(FullDIR):
    os.makedirs(FullDIR)


#Get the Correct file numbers that we need to download
PhyFun.GetPhysioData(PROJ, SUBJ, SESS)

#Download those Files
PhyFun.DownloadPhysioFiles(DIR, PROJ, SUBJ, SESS)

#open tmp.csv and store values into a dict
with open('tmp.csv', mode='r') as infile:
    reader = csv.reader(infile)
    trialIDDict = {rows[0]: rows[1][-2:] for rows in reader}
os.remove('tmp.csv')

#remove all rest and StroopTest physio files
trialIDDict = {key: value for key, value in trialIDDict.items()
             if ('Rest' not in key and 'Test' not in key)}

#Generalize Keys to make names more universal
for key, value in trialIDDict.items():
    trialIDDict[key[6:].replace(ABV, '').replace('_PhysioLog', '')] = trialIDDict.pop(key)

#Find Files and place in a dictionary with their scan number
#Make a dictionary With a Key of scan Number and a value of Filename
#move the files to the parent directory for the matlab script
scansPath = os.path.join(FullDIR, SUBJ+'_'+SESS,'scans')
for directory in os.listdir(scansPath):
    for root, dir, files in os.walk(os.path.join(scansPath,directory)):
        for name in files:
            fileNameDict[directory[:2]] = os.path.splitext(name)[0]
            shutil.copy(os.path.join(root, name), os.path.join(FullDIR, name))
shutil.rmtree(os.path.join(FullDIR, SUBJ+'_'+SESS))
print trialIDDict
print fileNameDict
#Merge the two Dictionaries resulting in Key of trial names and Value of filenames
PhyFun.mergeDictionaries(trialIDDict, fileNameDict)
#build a String of the matrix for the matlab file


# shutil.copy(OriginalTemplateConverter, '.')
uuids, runnames = PhyFun.BuildMatrix(trialIDDict)

#Place it into the Matlab file

print 'uuids = ' + (uuids)
print 'runnames = ' + (runnames)
# with open('template_convert.m', mode='r+b') as matlabFile:
#     allLines = matlabFile.read()
#     uuidsPos = allLines.find('uuids = [')
#     runnamesPos = allLines.find('runnames = [')
#     EndPos = allLines.find('[\'Stroop\' sessidshort \'2_PA\']];')
#     allLines = allLines[:uuidsPos + 7] + uuids + allLines[runnamesPos-1:runnamesPos+len(runnamesPos)-1] \
#                + runnames + allLines[EndPos+len(EndPos):]
#     matlabFile.seek(0)
#     matlabFile.truncate()
#     matlabFile.write(allLines)
# os.rename('template_convert.m', os.path.join(FullDIR, 'template_convert.m'))


