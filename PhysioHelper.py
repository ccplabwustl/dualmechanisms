# Purpose: To assist in generating the matlab matrix need to process the Physio Files
# Author: Mitchell Jeffers
# Date: 8/2/17

import os
import csv
import shutil
import subprocess

# get User Input

#TestValues:
DIR = '/home/mitchell/Desktop/DMCC_Phase2/Raw_Data'
SUBJ = '132017'
SESS = 'baseline'

# DIR = raw_input("ENTER THE DIRECTORY FILES DIRECTORY: ")
# SUBJ = str(input('ENTER SUBJECT NUMBER: '))
# SESS = raw_input('ENTER SESSION: ')
PROJ = 'DMCC_Phase2'
ABV = SESS[:3].capitalize()
trialIDDict = {}
fileNameDict = {}
OriginalTemplateConverter = '/home/mitchell/R01/Jo/physio/template_convert.m'
# TemplateConverterPath = '/scratch1/MitchJeffers/R01/Jo/physio/template_conterter.m'



#merge Dictionary one and two. use dict1's keys
# to find dict 2 values return store in dict1
def mergeDictionaries(dict1, dict2):
    for key, value in dict1.items():
        dict1[key] = dict2[dict1[key]]


#Build Matrix String based on
# runnames = [['Axcpt' sessidshort '1_AP ']; ['Axcpt' sessidshort '2_PA '];
#             ['Cuedts' sessidshort '1_AP']; ['Cuedts' sessidshort '2_PA'];
#             ['Stern' sessidshort '1_AP ']; ['Stern' sessidshort '2_PA '];
#             ['Stroop' sessidshort '1_AP']; ['Stroop' sessidshort '2_PA']];
#if Physio file for scan doesnt exist it will be replaced with a one
def BuildMatrix(dict1):
    uuidMatrix = '[\'' + dict1.get('Axcpt1_AP', '0') + '\'; \'' + dict1.get('Axcpt2_PA','0') + '\';\n'\
          + '\t\'' + dict1.get('Cuedts1_AP', '0') + '\'; \'' + dict1.get('Cuedts2_PA','0') + '\';\n'\
          + '\t\'' + dict1.get('Stern1_AP', '0') + '\'; \'' + dict1.get('Stern2_PA', '0') + '\';\n'\
          + '\t\'' + dict1.get('Stroop1_AP', '0') + '\'; \'' + dict1.get('Stroop2_PA', '0') + '\'];\n'
    return uuidMatrix


def GetPhysioData():
    # Get the list of physio Files and store in to tmp.csv
    os.system("curl -s -k -n https://intradb.humanconnectome.org/data/projects/"+PROJ+"/subjects/"\
              + SUBJ + "/experiments/" + SUBJ + "_" + SESS + \
              "/scans?format=csv | grep \"Physio\" | cut -d, -f7,8 > tmp.csv")

    print 'Downloading Physio Data from intraDB'
    #Download all the physio scans
    print 'bash intraDBPhysioDownload.sh -s '+SUBJ+' -e '+SESS+' -p '+PROJ+' -d '+DIR
    #os.system('bash intraDBPhysioDownload.sh -s '+SUBJ+' -e '+SESS+' -p '+PROJ+' -d '+DIR)

def findUUIDs(sn):
    baseScanNumber = [int(numbers) - 1 for numbers in sn]
    print baseScanNumber
    os.system('curl -k -n https://intradb.humanconnectome.org/data/projects/'+PROJ+'/subjects/'+SUBJ+\
                  '/experiments/'+SUBJ+'_'+SESS+'/scans?format=csv\&columns=xnat:mrScanData/fileNameUUID>UUID.csv')
        
GetPhysioData()

#open tmp.csv and stare values into a dict
with open('tmp.csv', mode='r') as infile:
    reader = csv.reader(infile)
    #scanNumbers = [rows[1][-2:] for rows in reader]
    #findUUIDs(scanNumbers)
    trialIDDict = {rows[0]: rows[1][-2:] for rows in reader}
os.remove('tmp.csv')
print trialIDDict
#remove all rest and StroopTest physio files
trialIDDict = {key: value for key, value in trialIDDict.items()
             if ('Rest' not in key and 'Test' not in key)}

#Generalize Keys to make names more universal
for key, value in trialIDDict.items():
    trialIDDict[key[6:].replace(ABV, '').replace('_PhysioLog', '')] = trialIDDict.pop(key)

#Find Files and place in a dictionary with their scan number
#Make a dictionary With a Key of scan Number and a value of Filename
#move the files to the parent directory for the matlab script
for directory in os.listdir(DIR):
    print directory
    for root, dirs, files in os.walk(os.path.join(DIR, directory)):
        for name in files:
            fileNameDict[directory[:2]] = os.path.splitext(name)[0]
            shutil.copy(os.path.join(root, name), os.path.join(DIR, name))
    #shutil.rmtree(directory)

#Merge the two Dictionaries resulting in Key of trial names and Value of filenames
mergeDictionaries(trialIDDict, fileNameDict)
#build a String of the matrix for the matlab file


shutil.copy(OriginalTemplateConverter, '.')
#Place it into the Matlab file
with open('template_convert.m', mode='r+b') as matlabFile:
    allLines = matlabFile.read()
    startPos = allLines.find('uuids = [')
    endPos = allLines.find('runnames = [')
    allLines = allLines[:startPos + 7] + BuildMatrix(trialIDDict) + allLines[endPos-1:]
    matlabFile.seek(0)
    matlabFile.truncate()
    matlabFile.write(allLines)
os.rename('template_convert.m', os.path.join(DIR, 'template_convert.m'))


