import os
import csv
import shutil
#SUBJ = str(input('ENTER SUBJECT NUMBER: '))
#SESS = raw_input('ENTER SESSION: ')
SUBJ = '132017'
SESS = 'baseline'
ABV = SESS[:3].capitalize()
trialIDDict = {}
fileNameDict = {}
WorkDir=os.path.join('/home','mitchell','Desktop','scans')

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
def BuildMatrix(dict1):
    uuids = '[\'' + dict1['Axcpt1_AP'] + '\'; \'' + dict1['Axcpt2_PA'] + '\';\n'\
          + '\'' + dict1['Cuedts1_AP'] + '\'; \'' + dict1['Cuedts2_PA'] + '\';\n'\
          + '\'' + dict1['Stern1_AP'] + '\'; \'' + dict1['Stern2_PA'] + '\';\n'\
          + '\'' + dict1['Stroop1_AP'] + '\'; \'' + dict1['Stroop2_PA'] + '\'];'
    return uuids
#Get the list of physio Files and store in to tmp.csv
os.system("curl -s -k -n https://intradb.humanconnectome.org/data/projects/DMCC_Phase2/subjects/"+SUBJ+"/experiments/"+SUBJ+"_"+SESS+"/scans?format=csv | grep \"Physio\" | cut -d, -f7,8 > tmp.csv")

#open tmp.csv and stare values into a dict
with open('tmp.csv', mode='r') as infile:
    reader = csv.reader(infile)
    trialIDDict = {rows[0]: rows[1][-2:] for rows in reader}

#remove all rest and StroopTest physio files
trialIDDict = {key: value for key, value in trialIDDict.items()
             if ('Rest' not in key and 'Test' not in key)}

#Generalize Keys to make names more universal
for key, value in trialIDDict.items():
    trialIDDict[key[6:].replace(ABV, '').replace('_PhysioLog', '')] = trialIDDict.pop(key)


print trialIDDict

#Find Files and place in a dictionary with their scan number
for directory in os.listdir(WorkDir):
    print directory
    for root, dirs, files in os.walk(os.path.join(WorkDir, directory)):
        for name in files:
            print name
            fileNameDict[directory[:2]] = os.path.splitext(name)[0]
            #os.rename(os.path.join(root, name), os.path.join(WorkDir, name))
    #shutil.rmtree(directory)
#             fileNameTable.root
#             print "Moving From: " + os.path.join(root, name)
#             print "To: " + os.path.join(WorkDir, name)
#
#             os.rename(os.path.join(root, name), os.path.join(WorkDir, name))
#
#

mergeDictionaries(trialIDDict, fileNameDict)
print BuildMatrix(trialIDDict)


