import os
import csv
import shutil

def mergeDictionaries(dict1, dict2):
    for key, value in dict1.items():
        dict1[key] = dict2[dict1[key]]


# Build Matrix String based on
# runnames = [['Axcpt' sessidshort '1_AP ']; ['Axcpt' sessidshort '2_PA '];
#             ['Cuedts' sessidshort '1_AP']; ['Cuedts' sessidshort '2_PA'];
#             ['Stern' sessidshort '1_AP ']; ['Stern' sessidshort '2_PA '];
#             ['Stroop' sessidshort '1_AP']; ['Stroop' sessidshort '2_PA']];
# if Physio file for scan doesnt exist it will be replaced with a one
def BuildMatrix(dict1):
    uuidMatrix = '[\'' + dict1.get('Axcpt1_AP', '0') + '\'; \'' + dict1.get('Axcpt2_PA', '0') + '\';\n' \
                 + '\t\'' + dict1.get('Cuedts1_AP', '0') + '\'; \'' + dict1.get('Cuedts2_PA', '0') + '\';\n' \
                 + '\t\'' + dict1.get('Stern1_AP', '0') + '\'; \'' + dict1.get('Stern2_PA', '0') + '\';\n' \
                 + '\t\'' + dict1.get('Stroop1_AP', '0') + '\'; \'' + dict1.get('Stroop2_PA', '0') + '\'];\n'
    return uuidMatrix


def GetPhysioData(project, subject, session):
    # Get the list of physio Files and store in to tmp.csv
    os.system("curl -s -k -n https://intradb.humanconnectome.org/data/projects/" + project + "/subjects/" \
              + subject + "/experiments/" + subject + "_" + session + \
              "/scans?format=csv | grep \"Physio\" | cut -d, -f7,8 > tmp.csv")

def DownloadPhysioFiles(directory, project, subject, session):
    print 'Downloading Physio Data from intraDB:'
    os.system('bash intraDBPhysioDownload.sh -s ' + subject + ' -e ' + session + ' -p ' + project + ' -d ' + directory)

def findUUIDs(sn, project, subject, session):
    baseScanNumber = [int(numbers) - 1 for numbers in sn]
    print baseScanNumber
    os.system('curl -k -n https://intradb.humanconnectome.org/data/projects/' + project + '/subjects/' + subject + \
              '/experiments/' + subject + '_' + session + '/scans?format=csv\&columns=xnat:mrScanData/fileNameUUID>UUID.csv')
