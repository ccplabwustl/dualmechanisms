code written by Joset A. Etzel (jetzel@wustl.edu) https://pages.wustl.edu/dualmechanisms   http://ccpweb.wustl.edu/
https://opensource.org/licenses/BSD-3-Clause 
Copyright 2018, Cognitive Control & Psychopathology Lab, Psychological & Brain Sciences, Washington University in St. Louis (USA)
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-------------------------------------------------------

These are knitr (R, https://www.r-project.org/) scripts for analyzing behavioral responses from the DMCC tasks, fMRI (NEUROIMAGING) version. If you are new to knitr, see https://yihui.name/knitr/ and http://mvpa.blogspot.com/2014/12/tutorial-knitr-for-neuroimagers.html to get started. 

Most documentation is in the knitr scripts, so please read the comments carefully. To compile the knitr scripts using the example data provided, all that should be required is to change the lines at the top of each script, immediately following the # **** change these lines comment. In particular, in.path needs to point to where the /NEUROIMAGING/exampleDataset/input/ files are located on your local machine.

Hints: while the knitrs for the example dataset are collected into a single directory, each knitr should be compiled in its own directory to avoid mixing images across files. I suggest that you copy the /analysisCode/ directory structure to your local machine, making a separate copy of the structure for each participant. The subject ID codes can then be inserted into each template file. Only the .rnw and .pdf files need to be saved; the other files will be recreated when the .rnw is recompiled.

As time permits, I will add group analysis versions of this code, as well as code to write out .csv versions of the summary statistics and compile the knitrs for each subject in batches. Please contact me (Jo, jetzel@wustl.edu) with questions, bugs, comments, and feature requests.