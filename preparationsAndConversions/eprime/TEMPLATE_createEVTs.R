# code written by Joset A. Etzel (jetzel@wustl.edu) https://pages.wustl.edu/dualmechanisms   https://sites.wustl.edu/ccplab/

# https://opensource.org/licenses/BSD-3-Clause 
# Copyright 2018, Cognitive Control & Psychopathology Lab, Psychological & Brain Sciences, Washington University in St. Louis (USA)
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the 
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#########################################################################################################################################################
#########################################################################################################################################################

# This code creates afni-format stimulus timing files ("EVTs") for running the typical DMCC GLMs. Its input is the csv-formatted version of the 
# eprime files made by \dualmechanisms\preparationsAndConversions\eprime\TEMPLATE_convertEprime.R (https://github.com/ccplabwustl/dualmechanisms),
# named such as SUBID_baseline_AxcptBas_run1.txt_raw.csv.

# note: The DMCC team stores the input (csv files) in a shared, secure box repository. This function thus has flags so that when it is run by 
# DMCC project team members at Washington University in St. Louis it will automatically download the files from the proper box locations. 
# Since this code is expected to primarily be run by DMCC team members, it defaults to the settings we need.
# To run the code elsewhere (or without automatic box downloading), set wustl.box <- FALSE.

# Whether this code is being run with box at wustl or not, it writes local copies of the files to a new sub.id temp.path subdirectory   

rm(list=ls());   # clear R's workspace to start fresh
options(warnPartialMatchDollar=TRUE);   # safety option. boxr functions warn "partial match of 'cat' to 'category'"; disregard. 


#**** change the lines of code below here ****#

wustl.box <- TRUE;   # if a DMCC team member is running this code (downloads the eprime csv input from box)

sub.id <- "150423";  #  subject id. (in quotes, even if the subject id is all numbers.)
which.DMCC <- 2;    # which.DMCC <- 3;  # DMCC phase number (e.g. which.DMCC <- 3 for the second wave of scans, DMCC_Phase3)

temp.path <-  "d:/temp/evts/";     # path to a local directory where the files will be written (in a sub.id subdirectory).

# download evtFileMaker.R from https://github.com/ccplabwustl/dualmechanisms/tree/master/preparationsAndConversions/eprime/
code.fname <- "d:/gitFiles_ccplabwustl/dualmechanisms/preparationsAndConversions/eprime/evtFileMaker.R";  # local path to evtFileMaker.R

# in.path isn't used if wustl.box <- TRUE;  
if (wustl.box == FALSE) { in.path <- "d:/temp/"; }  # path to eprime txt_raw.csv files for this person (written by TEMPLATE_convertEprime.R)



#**** should not need to change the lines of code below here ****#

# check evtFileMaker.R
if (file.exists(code.fname)) { source(code.fname); } else { stop(paste("missing:", code.fname)); }
if (!exists("do.Axcpt")) { stop("source(evtFileMaker.R) failed; check code.fname variable"); }


if (wustl.box == TRUE) {      # set variables needed to run this code at wustl and interact with box
  if (require(boxr) == FALSE) { stop("did not find the boxr library but wustl.box == TRUE"); }   # https://github.com/r-box/boxr
  
  if (which.DMCC == 2) { folder.num <- '8763934801'; }  # box ID for DMCC_Phase2(HCP) / Preprocessed_Data 
  if (which.DMCC == 3) { folder.num <- '31453535133'; }  # box ID for DMCC_Phase3 / Preprocessed_Data
  if (which.DMCC == 4) { folder.num <- '134612671901'; }  # box ID for DMCC_Phase4 / Preprocessed_Data 
  
  box_auth();   # initiate the link to box. 
}

# make the output directory under temp.path if it doesn't already exist 
out.path <- paste0(temp.path, sub.id, "/");   
if (!dir.exists(out.path)) { dir.create(out.path); }


# actually make the evt files for each task.
# if all runs are complete (should go into the evt files), leave the good.TASK variable complete 
# (good.TASK <- c("Bas1", "Bas2", "Pro1", "Pro2", "Rea1", "Rea2");). But if a run should be skipped, replace its name with NA.
# For example, if run 2_AP of Sternberg BAS ended early: good.Stern <- c("Bas1", NA, "Pro1", "Pro2", "Rea1", "Rea2");
# Setting the good.TASK spot to NA should let R make all of the other evt files for that task. If the run is incomplete,
# but more than half was collected, ask Jo (set a basecamp task) to see if evts can be made for the partial run.

good.Axcpt <- c("Bas1", "Bas2", "Pro1", "Pro2", "Rea1", "Rea2");
out.Axcpt <- do.Axcpt(sub.id, which.DMCC, good.Axcpt);

good.Cuedts <- c("Bas1", "Bas2", "Pro1", "Pro2", "Rea1", "Rea2");
out.Cuedts <- do.Cuedts(sub.id, which.DMCC, good.Cuedts);

good.Stern <- c("Bas1", "Bas2", "Pro1", "Pro2", "Rea1", "Rea2");
out.Stern <- do.Stern(sub.id, which.DMCC, good.Stern);

good.Stroop <- c("Bas1", "Bas2", "Pro1", "Pro2", "Rea1", "Rea2");
out.Stroop <- do.Stroop(sub.id, which.DMCC, good.Stroop);

if (length(out.Axcpt$err.str) > 1) { print(out.Axcpt$err.str); }
if (length(out.Cuedts$err.str) > 1) { print(out.Cuedts$err.str); }
if (length(out.Stern$err.str) > 1) { print(out.Stern$err.str); }
if (length(out.Stroop$err.str) > 1) { print(out.Stroop$err.str); }

if (length(list.files(out.path)) == 154) { print(paste("good! found 154 evts in", out.path)); }


# look if anything is printed in between these last lines, like this:
# in this case, 233326 AxcptRea2 is a known missing, so all is ok. 
# > if (length(tmp1) > 1) { print(tmp1); }
# [1] ""                                       "missing: \"233326_reactive_AxcptRea_run2.txt_raw\""
# > if (length(tmp2) > 1) { print(tmp2); }
# > if (length(tmp3) > 1) { print(tmp3); }
# > if (length(tmp4) > 1) { print(tmp4); }

# if no errors were printed, and the evt files look ok (two lines of numbers in each of the 154 files), copy to /scratch2/evts/.
#########################################################################################################################################################
