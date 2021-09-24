% code written by Joset A. Etzel (jetzel@wustl.edu) https://sites.wustl.edu/dualmechanisms   https://sites.wustl.edu/ccplab/

% https://opensource.org/licenses/BSD-3-Clause 
% Copyright 2018, Cognitive Control & Psychopathology Lab, Psychological & Brain Sciences, Washington University in St. Louis (USA)
% Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
% 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
% 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
% OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
% THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This code calls the functions to convert the physio files from CMRR/Siemens format to .csv.
% No operations (filtering, downsampling, etc.) are performed with this code; only the file format is changed. The output csv file
% has one row for each "tick" in the input file and one column for each collected channel, with the channel names in the first
% row, e.g. physio.ACQ, physio.EXT, physio.RESP, physio.PULS.

clear;

% Set the subject, session, and wave variables here, plus the paths for your local machine.
% This script requires the raw physio input files (Physio_20170605_171949_b60e2617-7884-435d-b471-2a2d97797317_Info.log) to be stored locally.
% Save a copy of this template in inpath (with the subject ID in the filename instead of "template") for running in matlab,
% and add it to the corresponding box Raw_Data physio_data directory (with the files before converting).
% Copy the resulting .csv files from outpath into the corresponding box Preprocessed_Data physio_data directory.

subid = '######';   % subject ID (surrounded by single quotes)
sessid = 'baseline'; sessidshort = 'Bas';   % session ID
% sessid = 'proactive'; sessidshort = 'Pro'; 
% sessid = 'reactive'; sessidshort = 'Rea'; 

which.dmcc = 2; % which.dmcc = 3;  % which.dmcc = 4;  % phase of DMCC data collection (wave 1 == DMCC2)

endname = '_Info.log';      % a set of .log files for each run (usual)
% endname =  '.dcm';    % if a dcm file for each run

% set input and output directories for this machine, plus path to matlab functions.
addpath '/Users/akizhner/Desktop/R01/Jo/physio/';   % add directory with readCMRRPhysio.m & convert1physio.m to matlab's path
if which.dmcc == 2
    inpath = ['/Users/akizhner/Desktop/DMCC_Phase2(HCP)/Raw_Data/' subid '/' subid '_' sessid '/physio_data/'];
    outpath = ['/Users/akizhner/Desktop/DMCC_Phase2(HCP)/Preprocessed_Data/' subid '/physio_data/']; 
else 
    inpath = ['/Users/akizhner/Desktop/DMCC_Phase' which.dmcc '/Raw_Data/' subid '/' subid '_' sessid '/physio_data/'];
    outpath = ['/Users/akizhner/Desktop/DMCC_Phase' which.dmcc '/Preprocessed_Data/' subid '/physio_data/']; 
end 


% Get the UUIDs for each **task** run (using PhysioHelper) and copy into the uuids variable below.
% Background: physio files are named by the scanner by the uuid session code. uuid session codes are long random-looking
% strings, with no obvious relationship to the scan time or protocol. It is best to use PhysioHelper to find the uuid for
% each run and create this variable, but if this is not possible it can be found in intradb.

% If a run is missing (e.g., person didn't do a run), make sure to delete it from BOTH the runnames and uuids array.
uuids = ['Physio_20170323_195248_939ddc48-0169-4a16-8a99-a6da2c3f9d7c'; 'Physio_20170323_200741_8a5e4e6f-eb30-41bf-928c-52e0b091cba1';
         'Physio_20170323_202055_d4e7ac37-bdad-4d5d-a3e0-c3cdeeb85260'; 'Physio_20170323_203626_c9cd3808-3875-4920-9323-865b31fd5efb';
         'Physio_20170323_192045_81f78cdf-4049-48a2-9bb4-8c9ae6f50d79'; 'Physio_20170323_193302_c2433adf-307e-4ed3-9978-bfe255c069ce';
         'Physio_20170323_185437_f8e3d21d-b801-4e10-9e6a-7d179040b07d'; 'Physio_20170323_190731_ad2cd4bf-ac97-4517-b659-73507d12c1e7'];
         
runnames = [['Axcpt' sessidshort '1_AP ']; ['Axcpt' sessidshort '2_PA '];
            ['Cuedts' sessidshort '1_AP']; ['Cuedts' sessidshort '2_PA']; 
            ['Stern' sessidshort '1_AP ']; ['Stern' sessidshort '2_PA '];
            ['Stroop' sessidshort '1_AP']; ['Stroop' sessidshort '2_PA']];
        
runnames = cellstr(runnames);   % https://www.mathworks.com/help/matlab/matlab_prog/cell-arrays-of-strings.html

% call the function to write out each physio file. Comment out known missings.
convert1physio(1, uuids, endname, runnames, inpath, outpath, subid)  % Axcpt 1
convert1physio(2, uuids, endname, runnames, inpath, outpath, subid)  % Axcpt 2
convert1physio(3, uuids, endname, runnames, inpath, outpath, subid)  % Cuedts 1
convert1physio(4, uuids, endname, runnames, inpath, outpath, subid)  % Cuedts 2
convert1physio(5, uuids, endname, runnames, inpath, outpath, subid)  % Stern 1
convert1physio(6, uuids, endname, runnames, inpath, outpath, subid)  % Stern 2
convert1physio(7, uuids, endname, runnames, inpath, outpath, subid)  % Stroop 1
convert1physio(8, uuids, endname, runnames, inpath, outpath, subid)  % Stroop 2



% Get the UUIDs for each **resting** run (using PhysioHelper) and copy into the uuids variable below.

% If a run is missing (e.g., person didn't do a run), make sure to delete it from BOTH the runnames and uuids array.
uuids = ['Physio_20170323_195248_939ddc48-0169-4a16-8a99-a6da2c3f9d7c'; 'Physio_20170323_200741_8a5e4e6f-eb30-41bf-928c-52e0b091cba1'];

runnames = [];
        
% PhysioHelper should put the correct numbers into the runnames variable
% (so just paste it above). But if not using PhysioHelper, uncomment the
% lines below to set the proper run numbers.
% if  strcmp(sessidshort, 'Bas')  
%     runnames = [['Rest' sessidshort '1_AP ']; ['Rest' sessidshort '2_PA ']];
% end
% if  strcmp(sessidshort, 'Pro')  
%     runnames = [['Rest' sessidshort '3_AP ']; ['Rest' sessidshort '4_PA ']];
% end
% if  strcmp(sessidshort, 'Rea')  
%     runnames = [['Rest' sessidshort '5_AP ']; ['Rest' sessidshort '6_PA ']];
% end

runnames = cellstr(runnames);   % https://www.mathworks.com/help/matlab/matlab_prog/cell-arrays-of-strings.html


% call the function to write out each physio file. Comment out known missings.
convert1physio(1, uuids, endname, runnames, inpath, outpath, subid)  % Rest AP
convert1physio(2, uuids, endname, runnames, inpath, outpath, subid)  % Rest PA



% note about CMRR R015 version physio:
% The scanner update on 6 March 2017 installed version R015 of the CMRR sequences. This software update
% included a change to the physio file format. We want to use the scanner physio setting "multiple", which
% will save the physio recordings both as DICOM files (which will be automatically uploaded to the intradb) and
% sets of .puls, .resp, etc. files (as before the upgrade), which are transferred off the scanner and uploaded
% into box and as linked data; see the SOPs. Saving both versions maximizes consistency between subjects collected
% before and after the update: nearly all subjects will have the .resp, .puls, etc files. Jo confirmed 22 March 2017
% that the DICOM and not-DICOM versions of the physio produce identical files, and the added storage with "multiple"
% is minuscule. CMRR updated readCMRRPhysio.m for the R015 release, which works on DICOM and not-DICOM files.

