import os
import csv
# Get the User input for each parameter
def getUserInput():

    COMP = '0'
    DIR = '0'
    PROJ = raw_input('Enter DMCC_Phase2 or DMCC Phase3: ')
    SUBJ = raw_input('Enter the subject number: ')
    SESS = raw_input('Enter the session: ')
    while((COMP != 'Yes') and (COMP != 'No')):
        COMP = raw_input('Compare generated filenames to local Dir? (Yes)/(No): ')
    if COMP == 'Yes':
        DIR = raw_input('Enter the path where your Info.log files are stored: ')
        while not os.path.exists(DIR):
            DIR = raw_input('Enter the path where your Info.log files are stored: ')
    return PROJ, SUBJ, SESS, COMP, DIR


#Get the list of trial with physio data, along with scan numbers like the following:
#tfMRI_CuedtsBas1_AP_PhysioLog,20
#tfMRI_CuedtsBas2_PA_PhysioLog,23
#tfMRI_StroopTest_AP_PhysioLog,26
#tfMRI_StroopBas1_AP_PhysioLog,29
def GetTrialInfo(directory, project, subject, session):
    filename = subject + '_' + session + '_' + 'trial.csv'
    os.system('bash TrialWithScanRequest.sh -s ' + subject + ' -e ' + session + ' -p ' + project + ' -d ' + directory)

    try:
        with open(os.path.join(directory, filename), mode='r') as infile:
            reader = csv.reader(infile)
            fileDict = {rows[1]: rows[0] for rows in reader}

    except:
        print 'ISSUE with csv:' + filename
    os.remove(os.path.join(directory, filename))
    return fileDict


#makes a CSVs with the UUIDS and scan Numbers then place those values into a
def GetUUIDInfo(directory, project, subject, session):
    filename = subject+'_'+session+'_'+'UUIDS.csv'
    os.system('bash ScanNumWithUUIDRequest.sh -s ' + subject + ' -e ' + session + ' -p ' + project + ' -d ' + directory)
    #Create a Dictionary out of the csv with the
    try:
        with open(os.path.join(directory, filename), mode='r') as infile:
            reader = csv.reader(infile)
            fileDict = {rows[0]: rows[1] for rows in reader}

    except:
        print 'ISSUE with csv:' + filename
    os.remove(os.path.join(directory, filename))
    return fileDict

    return scanUUID


def DictCleanup(dict1, ABV):
    # remove all rest and StroopTest physio files
    dict1 = {key: value for key, value in dict1.items()
            if ('Rest' not in key and 'Test' not in key)}
    # Generalize Keys to make names more universal, by removing the Abreviation
    for key, value in dict1.items():
        dict1[key[6:].replace(ABV, '').replace('_PhysioLog', '')] = dict1.pop(key)
    return dict1


#merges the dictionaries to using the Keys in dict1 and the values from dict2
def mergeDictionaries(dict1, dict2):
    dictMerge = {}
    for key, value in dict1.items():
        dictMerge[key] = dict2[dict1[key]]
    return dictMerge


#Finds the longest value of the dictionary and returns the length
def FindMaxLengthValue(dictionary):
    keyLongestName = max(dictionary, key = lambda k: len(dictionary[k]))
    return len(dictionary[keyLongestName])

#Removes Values that are not present in the loacl Dir
def CompareWithLocal(oldDict, directory):
    newDict = {}
    for key in oldDict.keys():
        if os.path.exists(os.path.join(directory, oldDict[key] + '_Info.log')):
            newDict[key] = oldDict[key]
    return newDict


# Build Matrix String based on
# runnames = [['Axcpt' sessidshort '1_AP ']; ['Axcpt' sessidshort '2_PA '];
#             ['Cuedts' sessidshort '1_AP']; ['Cuedts' sessidshort '2_PA'];
#             ['Stern' sessidshort '1_AP ']; ['Stern' sessidshort '2_PA '];
#             ['Stroop' sessidshort '1_AP']; ['Stroop' sessidshort '2_PA']];
# if Physio file for scan doesnt exist it will be replaced with a blank space
# all stings within an array must be the same length so padding is added on to the end of the file names and the
def BuildMatrix(dict1):

    if bool(dict1):
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
    else:
        uuidMatrix = 'no value'
        runnames =   'no value'
    return uuidMatrix, runnames