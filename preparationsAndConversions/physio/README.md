This code is used in the DMCC project to convert the CMRR-format physiological recordings collected during fMRI.
For more information, contact Joset A. Etzel (jetzel@wustl.edu), https://sites.wustl.edu/dualmechanisms  https://sites.wustl.edu/ccplab/

This and accompanying files are from https://github.com/ccplabwustl/dualmechanisms. More information on how to use these files and how they fit into the DMCC project is available in the "Physio Pre-Processing" section of the SOPs, at https://osf.io/6r9f8/. 


#### Software requirements:
1. MATLAB
   - We have tested this with versions R2017a (9.2.0) and R2015b (8.6.0.267246); other versions should also be ok.
2. readCMRRPhysio.m https://github.com/CMRR-C2P/MB/blob/master/readCMRRPhysio.m
   - Put into a location on MATLAB's PATH or change the addpath line in template_convert.m (in this repository) to its location.
3. convert1physio.m (in this repository)
   - Put into a location on MATLAB's PATH or into the same directory as readCMRRPhysio.m (so the addpath command allows MATLAB to find both files).

#### Running:   
1. Copy all the raw physio files for a single subject, session, and wave to a local directory.
2. Make a local copy of template_convert.m (replacing template with the subject ID) and save in this same local directory.
3. Set the template_convert.m variables to specify the subject, session, and wave, as well as the local paths.
4. Fill out the uuids arrays for each run with the PhysioHelper output or the intradb session information.
5. Run the code, producing one .csv file for each run.


#### Notes:
1. The DMCC project uses CMRR multiband fMRI acquisition sequences (https://www.cmrr.umn.edu/multiband/) on a Siemens Prisma, with the Siemens finger photoplethysmograph and respiration belt equipment; this code is unlikely to work with files collected using other hardware or software.
2. We use the PhysioHelper program to retrieve the UUIDs associated with each scan from our XNAT database. The PhysioHelper code is only for internal use, and is not expected to work elsewhere, but is included here for completeness and in case it is a useful reference for developing your own version. It is possible to use the matlab and R portions of the pipeline without PhysioHelper by retrieving the UUIDs directly.
3. This code converts physio files from CMRR/Siemens format to .csv; no operations (filtering, downsampling, etc.) are performed. A single .csv file is produced for each run. The output files have one row for each "tick" in the input file and one column for each channel. The channel name identifying each channel are listed in the first row, e.g. physio.ACQ, physio.EXT, physio.RESP, physio.PULS. Columns will only be created for channels with data (e.g., if no photoplethysmograph data is found the physio.PULS file will not be included).



https://opensource.org/licenses/BSD-3-Clause
Copyright 2020, Cognitive Control & Psychopathology Lab, Psychological & Brain Sciences, Washington University in St. Louis (USA)
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the 
   documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
