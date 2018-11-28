code written by Joset A. Etzel (jetzel@wustl.edu) https://pages.wustl.edu/dualmechanisms   http://ccpweb.wustl.edu/
https://opensource.org/licenses/BSD-3-Clause 
Copyright 2018, Cognitive Control & Psychopathology Lab, Psychological & Brain Sciences, Washington University in St. Louis (USA)
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-------------------------------------------------------

This example dataset consists of files for three participants, 102008, 132017, and 165032. The files for each participant are in a directory labeled with their subject ID. Summary files can be generated for each of these participants, and should look like the examples in the /output/ directories when compiled. A slightly different collection of files are provided for each participant to show variations.

The main type of input files are the eprime erecovery files produced by the DMCC eprime scripts for the fMRI task, requested from http://pages.wustl.edu/dualmechanisms/. However, the code will also accept (and generate) comma-delimited (csv) files, examples of which are in subject 132017. Only some of these columns are required; see the .rnw code for the names of the needed columns (extra columns are not harmful). 

Only include files for runs and sessions that the participant completed. For example, 102008 only has files for  the baseline session because they did not complete proactive or reactive.

Stroop requires more files than just the eprime output for full scoring, because of the verbal responses. The _ACC.csv files contain one essential column, ACC.Final, with one row for each trial in that session, in order (run 1 then run 2). 1 indicates trials with the correct response, 0 an incorrect response, and other words (e.g., "unintelligible", see 165032_baseline_StroopBas_ACC.csv) for special cases. Only 1 trials are scored as correct and 0 as incorrect; other values are treated as "scratch" trials and not included in the accuracy calculation. We create these files "manually"; two people listen to each recorded response and enter what they heard (Listener.1 and Listener.2 columns), the heard words are checked for consistency, then scored.

The _extractedRTs.csv files have the RT for each trial, calculated by matlab code from the audio .wav files. We have found that each microphone requires a different RT-extracting script; please contact us for more details and example scripts.


