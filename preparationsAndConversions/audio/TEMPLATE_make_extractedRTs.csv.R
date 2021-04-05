# code written by Joset A. Etzel (jetzel@wustl.edu) https://pages.wustl.edu/dualmechanisms   https://sites.wustl.edu/ccplab/
# This code is part of the audio Stroop RT extraction pipeline used in the DMCC project.
# this and accompanying files are from https://github.com/ccplabwustl/dualmechanisms.
# More information on how to use these files and how they fit into the DMCC project is available in the "Behavioral Pre-Processing" 
# section of the SOPs, at https://osf.io/pycm7/
# (direct link https://mfr.osf.io/render?url=https://osf.io/pycm7/?direct%26mode=render%26action=download%26mode=render).


# https://opensource.org/licenses/BSD-3-Clause 
# Copyright 2020, Cognitive Control & Psychopathology Lab, Psychological & Brain Sciences, Washington University in St. Louis (USA)
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
# template code for creating _extractedRTs.csv files, which collect the Stroop trial type and detected RTs for a single person and session.
# _extractedRTs.csv files are read by later DMCC-written analysis code, and we find them to be a convenient summary, but they are not required.
# This code makes the _extractedRTs.csv files by parsing and rearranging parts of the three files created by TEMPLATE_extractRTs.m (RTs_energy.txt, 
# RTs_silencedet_energy1.txt, RTs_silencedet_energy2.txt), together with the eprime .csvs created by TEMPLATE_convertEprime.R, but does not change any
# of these values or perform other calculations on them.

# This code is expected to primarily be run by DMCC team members, so it defaults to the settings we need. In particular, we store the files produced
# by this code (_extractedRTs.csv) in a shared, secure box repository. This function thus has flags so that when it is run by DMCC project team 
# members at Washington University in St. Louis it will automatically upload the files to the proper box locations.
# To run the code elsewhere (or without automatic box up/downloading), set wustl.box <- FALSE.

# note: this code requires that two complete Stroop runs were performed for the person and session. If this is not the case (i.e., there are missings)
# this code will fail, and must be manually edited if a file with partial results is desired.

# note: if wustl.box == TRUE the eprime files will be read from box (if not present locally), and the output files will be uploaded to box. 
# The code will ALWAYS read the _RTs_energy.txt and other files written by matlab locally (under temp.path). It also always writes the _extractedRTs.csv
# for each session locally, and also tries to upload to box if wustl.box == TRUE.


rm(list=ls());   # clear R's workspace to start fresh
options(warnPartialMatchDollar=TRUE);   # safety option. boxr functions warn "partial match of 'cat' to 'category'"; disregard. 


#**** change the lines of code below here ****#

wustl.box <- TRUE;   # if a DMCC team member is running this code (includes automatic box upload)
reupload <- FALSE;   # whether to attempt to reupload files to box, even if already present. ignored if wustl.box == FALSE.
# files not already on box will always be uploaded if wustl.box == TRUE; this is whether to replace ones already present.

sub.id <- "132017";  #  subject id. (in quotes, even if the subject id is all numbers.)
which.DMCC <- 2;    # which.DMCC <- 3;  # DMCC phase number (e.g. which.DMCC <- 3 for the second wave of scans, DMCC_Phase3)

temp.path <-  "d:/temp/";     # path to a local directory where files will be read and written as the code runs.
# temp.path should point to the same place as in TEMPLATE_extractRTs.m.
# the subject's wav files should be in temp.path/sub.id/sub.id_session.id/Stroop/audiofiles/. 
# the output files (_extractedRTs.csv) are written to temp.path/sub.id/ProcessedData/, and uploaded to box if wustl.box == TRUE.

#**** should not need to change the lines of code below here ****#


session.ids <- c("baseline", "proactive", "reactive");
sess.ids <- c("Bas", "Pro", "Rea");      # abbreviated session.ids, in same order.
sess.ids.stroop <- c("LWMC", "LWMI", "ISPC");    # Stroop session.ids, in same order.
need.lengths <- c(216, 216, 240);  # how many trials must be in the matlab-created RT files; same order as session.ids

if (wustl.box == TRUE) {      # set variables needed to run this code at wustl and interact with box
  if (require(boxr) == FALSE) { stop("did not find the boxr library but wustl.box == TRUE"); }   # https://github.com/r-box/boxr
  
  if (which.DMCC == 2) { 
    ancestor.raw <- '8763934993';   # box ID for DMCC_Phase2(HCP) / Raw_Data 
    ancestor.prep <- '8763934801';   # box ID for DMCC_Phase2(HCP) / Preprocessed_Data 
  }
  if (which.DMCC == 3) { 
    ancestor.raw <- '31298436958';   # box ID for DMCC_Phase3 / Raw_Data 
    ancestor.prep <- '31453535133';   # box ID for DMCC_Phase3 / Preprocessed_Data 
  }
  if (which.DMCC == 4) { 
    ancestor.raw <- '134612426355';   # box ID for DMCC_Phase4 / Raw_Data 
    ancestor.prep <- '134612671901';   # box ID for DMCC_Phase4 / Preprocessed_Data 
  }
  
  box_auth();   # initiate the link to box. 
}


# make the output directory under temp.path if it doesn't already exist.
# output files will be written here even if wustl.box == TRUE (have to be written before uploading to box).
# the paths should work without altering to read in the files written by TEMPLATE_extractRTs.m.
out.path <- paste0(temp.path, sub.id, "/"); 
if (!dir.exists(out.path)) { dir.create(out.path); }
out.path <- paste0(temp.path, sub.id, "/ProcessedData");    # NO trailing slash (for box_dl compatibility)
if (!dir.exists(out.path)) { dir.create(out.path); }


# loop over the sessions and actually make (and perhaps upload) the _extractedRTs.csv files.
for (ssid in 1:length(session.ids)) {      # ssid <- 1;
  if (exists("e.tbl")) { rm(e.tbl); }   # clean R memory
  e.tbl1 <- NA; e.tbl2 <- NA;    # assign empty variables, also to start this session's loop cleanly.
  
  # read in the eprime input files (for the task labels). First look locally, then from box (if wustl.box == TRUE)
  fname1 <- paste0(temp.path, sub.id, "/Stroop/", sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], "_run1.txt_raw.csv");    
  if (file.exists(fname1)) { e.tbl1 <- read.csv(fname1); }
  fname2 <- paste0(temp.path, sub.id, "/Stroop/", sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], "_run2.txt_raw.csv");    
  if (file.exists(fname2)) { e.tbl2 <- read.csv(fname2); }
  
  if (length(e.tbl1) == 1 & wustl.box == TRUE) {    # file not local; try to read it from box
    fname1 <- paste0('"', sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], '_run1.txt_raw"'); 
    boxr1 <- box_search(fname1, type='file', file_extensions='csv', ancestor_folder_ids=ancestor.prep); 
    if (length(boxr1) == 1) { e.tbl1 <- box_read_csv(boxr1[[1]]$id); }
  }
  if (length(e.tbl1) == 1) { stop(paste0("didn't load ", sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], "_run1.txt_raw")); }
  
  if (length(e.tbl2) == 1 & wustl.box == TRUE) {    # file not local; try to read it from box
    fname2 <- paste0('"', sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], '_run2.txt_raw"'); 
    boxr2 <- box_search(fname2, type='file', file_extensions='csv', ancestor_folder_ids=ancestor.prep); 
    if (length(boxr2) == 1) { e.tbl2 <- box_read_csv(boxr2[[1]]$id); }
  }
  if (length(e.tbl2) == 1) { stop(paste0("didn't load ", sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], "_run2.txt_raw")); }
  
  # have the eprime files, so start e.tbl with the needed columns.
  e.tbl <- rbind(e.tbl1[,c("LWPC", "TrialType")], e.tbl2[,c("LWPC", "TrialType")]);   # columns from the eprime output for the summary file.
  e.tbl <- e.tbl[which(!is.na(e.tbl$LWPC)),];  # get rid of NA rows - the fixation rows
  if (nrow(e.tbl) != need.lengths[ssid]) { print(paste("not the expected number of trials in", session.ids[ssid])); }  # check the right number of trials.  
  
  
  # read in the RTextractions files (made in TEMPLATE_extractRTs.m). there should be three files for each session; each file has both runs. 
  fname1 <- paste0(temp.path, sub.id, "/", sub.id, "_", session.ids[ssid], "/Stroop/RTextractions/", sess.ids.stroop[ssid], "/RTs_energy.txt");
  fname2 <- paste0(temp.path, sub.id, "/", sub.id, "_", session.ids[ssid], "/Stroop/RTextractions/", sess.ids.stroop[ssid], "/RTs_silencedet_energy1.txt");
  fname3 <- paste0(temp.path, sub.id, "/", sub.id, "_", session.ids[ssid], "/Stroop/RTextractions/", sess.ids.stroop[ssid], "/RTs_silencedet_energy2.txt");
  
  if (file.exists(fname1) & file.exists(fname2) & file.exists(fname3)) {   # MUST have all three, locally
    # add RTs_energy columns to e.tbl
    tmp1 <- read.table(fname1, stringsAsFactors=FALSE, header=TRUE);  
    if (nrow(tmp1) == nrow(e.tbl)) { 
      e.tbl <- data.frame(e.tbl, RTestimate_energy1=tmp1$RTestimate_energy1, RTestimate_energy2=tmp1$RTestimate_energy2);
    } else { stop(paste("mismatching row count:", fname1, "and e.tbl.")); } 
    
    # add RTs_silencedet_energy1 columns to e.tbl
    tmp1 <- read.table(fname2, stringsAsFactors=FALSE, header=TRUE, row.names=NULL);    
    if (nrow(tmp1) == nrow(e.tbl)) { 
      e.tbl <- data.frame(e.tbl, firstRTestimate_energy1=tmp1$firstRTestimate_energy1, secondRTestimate_energy1=tmp1$secondRTestimate_energy1);
    } else { stop(paste("mismatching row count:", fname2, "and e.tbl.")); } 
    
    # add RTs_silencedet_energy2 columns to e.tbl
    tmp1 <- read.table(fname3, stringsAsFactors=FALSE, header=TRUE, row.names=NULL);    
    if (nrow(tmp1) == nrow(e.tbl)) { 
      e.tbl <- data.frame(e.tbl, firstRTestimate_energy2=tmp1$firstRTestimate_energy2, secondRTestimate_energy2=tmp1$secondRTestimate_energy2);
    } else { stop(paste("mismatching row count:", fname3, "and e.tbl.")); } 
    
    
    # save the new file as a csv (always first write locally)
    out.fname <- paste0(out.path, "/", sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], "_extractedRTs.csv");
    write.csv(e.tbl, out.fname, row.names=FALSE);  
    if (!file.exists(out.fname)) { stop(paste("not written!", out.fname)); }
    
    
    if (wustl.box == TRUE) {     # try to upload the csv to box, if desired
      do.upload <- TRUE;
      if (reupload == FALSE) {     # need to check if output file already on box, so don't reupload
        f.bs <- box_search(paste0(sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], "_extractedRTs"), 
                           type='file', file_extensions='csv', ancestor_folder_ids=ancestor.prep);  
        if (length(f.bs) > 0) {   # might be present; check for exact name match 
          for (i in 1:length(f.bs)) {   # i <- 1;
            if (paste0(sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], "_extractedRTs.csv") == f.bs[[i]]$name) { 
              do.upload <- FALSE;   # found the match, so set flag not to upload again.
              break;
            }
          }
        }
      }
      
      if (do.upload == TRUE & file.exists(out.fname)) {    # the csv was written, and we want to upload it
        # find the upload folder id in box. annoying, since its name is just the task. So need to find the person's folder, than the task within person.
        folder.out1 <- box_search(paste0('"', sub.id, '"'), type='folder', ancestor_folder_ids=ancestor.prep);  # out to Preprocessed_Data
        if (length(folder.out1) == 1) {
          folder.out <- box_search(paste0('"Stroop"'), type='folder', ancestor_folder_ids=folder.out1[[1]]$id); # now task in person
        }
        if (length(folder.out) == 0) { print(paste("didn't find the box folder for", session.ids[ssid], "didn't upload to box.")); }
        if (length(folder.out) > 0) {    # might find more than one folder; /Stroop/ is usually the first spot
          if (folder.out[[1]]$name == "Stroop") {  
            tmp <- box_ul(dir_id=folder.out[[1]]$id, file=out.fname, );  
            if (length(tmp) > 1) { print(paste("success: uploaded", tmp$name, "to", tmp$parent$name)); }
          } else {
            print(paste("didn't find the box folder for", session.ids[ssid], "didn't upload to box."));
          }
        }
      }
    }   # end wustl.box upload section
    
  } else {    # at least one of the three input files was not found, so check for missing and list path(s)
    if (!file.exists(fname1)) { print(paste("missing", fname1)); }
    if (!file.exists(fname2)) { print(paste("missing", fname2)); }
    if (!file.exists(fname3)) { print(paste("missing", fname3)); }
  }
}

#########################################################################################################################################################


