This code is part of the audio Stroop RT extraction pipeline used in the DMCC project.
For more information, contact Joset A. Etzel (jetzel@wustl.edu), https://pages.wustl.edu/dualmechanisms  https://sites.wustl.edu/ccplab/

This and accompanying files are from https://github.com/ccplabwustl/dualmechanisms. More information on how to use these files and how they fit into the DMCC project is available in the "Behavioral Pre-Processing" section of the SOPs, at https://osf.io/pycm7/ (direct link https://mfr.osf.io/render?url=https://osf.io/pycm7/?direct%26mode=render%26action=download%26mode=render). 

Warning: There is no gurantee that this code will work well for extracting RTs from other fMRI audio recordings. We tested this code by comparing the RTs it extracts to those measured by human listeners, adjusting code parameters as needed for a good fit. Modification to the code and/or parameters will likely be needed for accurate detection in other settings, particularly if the fMRI acquisition, spoken words, or microphone are different than used in the DMCC.


#### Requirements:
1. Sox http://sox.sourceforge.net/ 
   - install and add to PATH; if nonstandard install, change line 4 of Normalize.sh
2. MATLAB
   - We have tested this with versions R2017a (9.2.0) and R2015b (8.6.0.267246); other versions should also be ok.
   - The signal processing toolbox is required for the Matlab Audio Analysis Library.
3. Matlab Audio Analysis Library https://www.mathworks.com/matlabcentral/fileexchange/45831-matlab-audio-analysis-library
   - specify installation directory at top of TEMPLATE_extractRTs.m
4. The files in the 'rt_v1.4' subdirectory (in this repository). Sources for these files are listed in 'rt_v1.4/README.md'. 

#### Running:   
1. Make a copy of TEMPLATE_extractRTs.m, replacing TEMPLATE with the subject ID.
2. Edit the variables:
   - bas_dir: path where your wave files live. The Directory Structure should be like: 'bas_dir/DMCC6960387/DMCC6960387_baseline/Stroop/audiofiles/*.wav'
   - FOMRI3Mic: A boolean for if the run used a FOMRI3Mic microphone to record subject responses
   - subjects: a list of strings representing the subjects you wish to run. ex.{'DMCC6960387'}
   - sessions: a list of strings representing the sessions you wish to run. ex.{'baseline'}
   - addpath('./audioAnalysisLibraryCode/library')  %point this towards your directory where this library lives (URL above). 
3. Run the Code


#### Explanations/Notes:
1. Estimating RTs with energy and spectral subtraction only:
   - This will generate an audio file with suffix '_energy#.WAV' where # is the audio channel of the original signal (i.e, if stereo, energy1.WAV for channel 1 and energy2.WAV for channel 2) 
   - Usage: c_seriesRT(origin, destination, audiocapture_onset, condition)  
   - Example: c_seriesRT('../data/ST008/108_LWMI', 'ST008/LWMI', 0.1, 'LWMI')
2. Apply a silence/word detector to the energy signals generated previously: 
   - This will generate an audio file with suffix '_silencedet#.WAV' where # is the number of the energy signal calculated from the audio channel of the original signal in step 1.
        
        Usage: 
        [fileslist, firstestimateRT, secondestimateRT] = c_silence_detector(origin, input_suffix, output_string)
        
        Example:
        [files_energy1, estimate1_energy1, estimate2_energy1] = c_silence_detector('./ST008/LWMI', '*energy1.wav', '_silencedet1') 
        [files_energy2, estimate1_energy2, estimate2_energy2] = c_silence_detector('./ST008/LWMI', '*energy2.wav', '_silencedet2') 
    
        In the example:
            estimate1_energy1 =  is the first estimated RT for energy signal 1
            estimate2_energy1 = is the second estimated RT (usually more accurate) for energy signal 1
        
            estimate1_energy2 = is the first estimated RT for energy signal 2
            estimate2_energy2 = is the second estimated RT (usually more accurate) for energy signal 2
      
            files_energy#: cell array of files, to parse response time estimates.

3. We recommended doing a visual QC (for example, open WAV files in Audacity. The response onsets detected by human listeners and the code should be tightly correlated.
4. Values of NaN will be generated when no word is detected, by any of the above methods. In this case, a WAV file will not be generated.


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
