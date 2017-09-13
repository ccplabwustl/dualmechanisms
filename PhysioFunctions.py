import os
import shutil
import csv
# Get the User input for each parameter
def getUserInput():

    DIR = raw_input("Enter the directory where your \'DMCC_Phase2(HCP)\' is located: ")
    #PROJ = raw_input('Enter DMCC_Phase2 or DMCC Phase3: ')
    PROJ = 'DMCC_Phase2'
    SUBJ = str(input('Enter the subject number: '))
    SESS = raw_input('Enter the session: ')

    return DIR, PROJ, SUBJ, SESS

#Get the list of physio Files and store in to tmp.csv
def GetPhysioData(directory, project, subject, session):
    os.system("curl -s -k -n https://intradb.humanconnectome.org/data/projects/" + project + "/subjects/" \
              + subject + "/experiments/" + subject + "_" + session + \
              "/scans?format=csv | grep \"Physio\" | cut -d, -f7,8 > " + os.path.join(directory, 'tmp.csv'))

#merges the dictionaries to using the Keys in dict1 and the values from dict2
def mergeDictionaries(dict1, dict2):
    dictMerge = {}
    print dict1
    print '\n\n'
    print dict2
    for key, value in dict1.items():
        dictMerge[key] = dict2[dict1[key]]
    return dictMerge

#Finds the longest value of the dictionary and returns the length
def FindMaxLengthValue(dictionary):
    keyLongestName = max(dictionary, key = lambda k: len(dictionary[k]))
    return len(dictionary[keyLongestName])

# Build Matrix String based on
# runnames = [['Axcpt' sessidshort '1_AP ']; ['Axcpt' sessidshort '2_PA '];
#             ['Cuedts' sessidshort '1_AP']; ['Cuedts' sessidshort '2_PA'];
#             ['Stern' sessidshort '1_AP ']; ['Stern' sessidshort '2_PA '];
#             ['Stroop' sessidshort '1_AP']; ['Stroop' sessidshort '2_PA']];
# if Physio file for scan doesnt exist it will be replaced with a blank space
# all stings within an array must be the same length so padding is added on to the end of the file names and the
def BuildMatrix(dict1):
    maxLength = FindMaxLengthValue(dict1)

    ExpectedTrialList = ['Axcpt1_AP', 'Axcpt2_PA','Cuedts1_AP', 'Cuedts2_PA',\
                         'Stern1_AP', 'Stern2_PA', 'Stroop1_AP','Stroop2_PA']
    uuidMatrix = '['
    runnames = '['
    for trial in ExpectedTrialList:
        if trial in dict1:

            uuidMatrix = uuidMatrix + '\''+dict1[trial].ljust(maxLength)+'\';'
            run = trial[:-4] + '\' sessidshort \'' + trial[-4:]
            runnames = runnames + '[\'' + run.ljust(25) + '\'];'

        if '2' in trial:
            uuidMatrix = uuidMatrix + '\n\t\t'
            runnames = runnames + '\n\t\t\t'

    uuidMatrix = uuidMatrix + '];\n'
    runnames = runnames + '];\n'

    return uuidMatrix, runnames

#Removes IntraDB file structure while looking at the scan numbers and file names to build a
def BuildDCMDict(directory, subject, session ):
    DCMDict = {}
    #Find Files and place in a dictionary with their scan number
    #Make a dictionary With a Key of scan Number and a value of Filename
    #move the files to the parent directory for the matlab script
    scansPath = os.path.join(directory, subject+'_'+session,'scans')
    for directories in os.listdir(scansPath):
        for root, dir, files in os.walk(os.path.join(scansPath,directories)):
            for name in files:
                DCMDict[directory[:2]] = os.path.splitext(name)[0]
                shutil.copy(os.path.join(root, name), os.path.join(directory, name))
    shutil.rmtree(os.path.join(directories, subject+'_'+session))
    return DCMDict

#Download the physio files to the directory folder
def DownloadDCMFiles(directory, project, subject, session):
    print 'Downloading Physio Data from intraDB:'
    os.system('bash intraDBPhysioDownload.sh -s ' + subject + ' -e ' + session + ' -p ' + project + ' -d ' + directory)



#makes a CSVs with the UUIDS and scan Numbers then place those values into a
def findUUIDs(directory, project, subject, session):

    # #request the list of UUIDs and scan numbers from intraDB
    # # then trim the list to only include lines that are scans with grep \'scans\'
    # # then trim any lines that are missing parameters with grep -Ev $\'^,|,,|,$\'
    # # then remove all the SBRef scans with grep -v \'SBRef\'
    # # then leave only fields 2 and 6 in the csv with cut -d, -f2,6
    # # finally remove duplicates with awk -F, \'!seen[$1]++\'
    os.system('curl -k -n https://intradb.humanconnectome.org/data/projects/'+project+'/subjects/'+ subject+'/experiments/'+\
    subject+'_'+session+'/scans?format=csv\&columns=xnat:imageScanData/image_session_ID,ID,type,series_description,'+\
    'xnat:mrScanData/fileNameUUID,URI |grep \'scans\'|grep -Ev $\'^,|,,|,$\' | grep -v \'SBRef\' | cut -d, -f2,6 > \''+\
    os.path.join(directory,'UUIDS.csv') + '\'')

    #Create a Dictionary out of the csv with the
    with open(os.path.join(directory, 'UUIDS.csv'), mode='r') as infile:
        reader = csv.reader(infile)
        trialFileDict = {rows[1]: rows[0] for rows in reader}
    os.remove(os.path.join(directory, 'UUIDS.csv'))

    return trialFileDict

def DictCleanup(dict1, ABV):
    # remove all rest and StroopTest physio files
    dict1 = {key: value for key, value in dict1.items()
            if ('Rest' not in key and 'Test' not in key)}
    # Generalize Keys to make names more universal, by removing the Abreviation
    for key, value in dict1.items():
        dict1[key[6:].replace(ABV, '').replace('_PhysioLog', '')] = dict1.pop(key)
    return dict1