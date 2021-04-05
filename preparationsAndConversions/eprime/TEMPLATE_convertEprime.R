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
# template code for converting the DMCC eprime text recovery files to csv format. The eprime files to present the task (and which make the input
# files for this function) are available from https://pages.wustl.edu/dualmechanisms/tasks.

# note: The DMCC team stores both the input (eprime text recovery files) and output (csv files) in a shared, secure box repository. This function
# thus has flags so that when it is run by DMCC project team members at Washington University in St. Louis it will automatically download and upload
# the files to the proper box locations. Since this code is expected to primarily be run by DMCC team members, it defaults to the settings we need.
# To run the code elsewhere (or without automatic box downloading and uploading), set wustl.box <- FALSE and local input and output directories.

# Whether this code is being run with box at wustl or not, it reads and writes local copies of the files. temp.path should be set to a directory
# in which these files can be written. The code will not overwrite files/directories if they already exist, so if it needs to be rerun 
# delete any previously-made files (for the particular subject and wave) from temp.path.

rm(list=ls());   # clear R's workspace to start fresh
options(warnPartialMatchDollar=TRUE);   # safety option. boxr functions warn "partial match of 'cat' to 'category'"; disregard. 

# edatparser library functions convert the eprime e-erecovery text files. edatparser is Copyright (c) 2015 Andy Hebrank 
if (require(edatparser) == FALSE) { print("did not find edatparser; please install"); }   # https://github.com/ahebrank/edatparser 


#**** change the lines of code below here ****#

wustl.box <- TRUE;   # if a DMCC team member is running this code (includes automatic download and upload from box)
reupload <- FALSE;   # whether to attempt to reupload files to box, even if already present. ignored if wustl.box == FALSE.
                     # files not already on box will always be uploaded if wustl.box == TRUE; this is whether to replace ones already present.

sub.id <- "102008";  #  subject id. (in quotes, even if the subject id is all numbers.)
which.DMCC <- 2;    # which.DMCC <- 3;  # DMCC phase number (e.g. which.DMCC <- 3 for the second wave of scans, DMCC_Phase3)
temp.path <-  "d:/temp/";     # path to a local directory where files will be written as the code runs.


#**** should not need to change the lines of code below here ****#


task.ids.long <- c("AXCPT", "CuedTS", "Sternberg", "Stroop");     # longer task names used in some eprime or box files
task.ids <- c("Axcpt", "Cuedts", "Stern", "Stroop");   # normal task naming convention (same order as task.ids.long)
session.ids <- c("baseline", "proactive", "reactive");    
sess.ids <- c("Bas", "Pro", "Rea");     # abbreviated session.ids, same order.

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


# make the output directory under temp.path if it doesn't already exist 
out.path <- paste0(temp.path, sub.id);    # NO trailing slash (for box_dl)
if (!dir.exists(out.path)) { dir.create(out.path); }


# this function does the work; it's called from below
convert.eprime <- function(ssid, tid) {    # ssid <- 1; tid <- 1;
  msg <- paste("trying to do", session.ids[ssid], task.ids.long[tid]);  # start return message string
  
  for (rid in 1:2) {     # rid <- 1;
    local.fname <- paste0(out.path, "/", sub.id, "_", session.ids[ssid], "_", task.ids[tid], sess.ids[ssid], "_run", rid, ".txt"); 
    if (wustl.box == TRUE) {   # download the file if needed; find the box upload folder 
      if (!file.exists(local.fname)) {       # input file isn't already on disk; so try to download it from box
        folder.in <- box_search(paste0('"', sub.id, "_", session.ids[ssid], '"'), type='folder', ancestor_folder_ids=ancestor.raw);  # in from Raw_Data
        if (length(folder.in) != 1) { stop("didn't find the input folder on box?"); }
        fname <- paste0('"', sub.id, "_", session.ids[ssid], "_", task.ids[tid], sess.ids[ssid], "_run", rid, '"');  # name on box
        boxr.in <- box_search(fname, type='file', content_types="name", file_extensions='txt', ancestor_folder_ids=folder.in[[1]]$id);  # search for the file on box.com
        if (length(boxr.in) == 1) { box_dl(boxr.in[[1]]$id, local_dir=out.path); }    # found the right file, so download
      }
      
      # have to step through to be sure have the correct output folder, since its name is just the task.
      folder.out1 <- box_search(paste0('"', sub.id, '"'), type='folder', ancestor_folder_ids=ancestor.prep);  # out to Preprocessed_Data
      if (length(folder.out1) == 1) {
        folder.out <- box_search(paste0('"', task.ids.long[tid], '"'), type='folder', ancestor_folder_ids=folder.out1[[1]]$id); # now task in person
      }
      if (length(folder.out1) == 0) { stop("didn't find the output folder on box?"); }
      if (length(folder.out1) > 1) {    # too many; check if any names match perfectly
        use.index <- 0;
        for (i in 1:length(folder.out1)) {   # i <- 1;
          if (folder.out1[[i]]$name == sub.id) { use.index <- i; }   # found the matching entry
        }
        if (use.index == 0) { stop("found multiple output folders on box, but not a match!"); }
        folder.out <- box_search(paste0('"', task.ids.long[tid], '"'), type='folder', ancestor_folder_ids=folder.out1[[use.index]]$id); # now task in person
      }
    }
    
    # should now have the file locally. if so, rearrange to a matrix and write as a csv.
    if (file.exists(local.fname)) {     
      if (R.version$major < 4) {      # version 4 of R requires a more complex procedure than previous, so check version first.
        edat.tbl <- as.data.frame(edat(local.fname));     # read in the erecovery text file and convert to a data.frame
      } else {    # version 4.0.0 and beyond
        edat.list <- edat(local.fname);   # read in the erecovery text file
        
        # all of the needed values are in edat.list$trial_info, but each entry only has columns the row has values for, so can't just read it in.
        trial.list <- edat.list$trial_info;
        
        # collect all the trial names.
        all.names <- names(trial.list[[1]]);   # start with the first row
        for (i in 2:length(trial.list)) { all.names <- union(all.names, names(trial.list[[i]])); }  # union the rest for a non-repeating set
        
        # now know the size of the output table needed, so make it and fill it up.
        edat.tbl <- data.frame(array(NA, c(length(trial.list), length(all.names))));
        colnames(edat.tbl) <- all.names;  
        for (i in 1:length(trial.list)) {   # i <- 1;
          this.row <- trial.list[[i]];
          for (j in 1:length(this.row)) {   # j <- 1;
            edat.tbl[i,names(this.row)[j]] <- this.row[j];
          }
        }
      }
      
      # the scanstart.RTTime: field is NOT included in the edatparser output file, so we need to read it from the input text and add it.
      tmp <- readLines(con <- file(local.fname, encoding="UCS-2LE"));  # specify windows encoding to avoid stray characters.
      close(con);    # clean up the connection to the input file
      scanstart.RTTime <- tmp[grep(pattern='scanstart.RTTime:', x=tmp)];   # find the line with scanstart.RTTime
      if (length(scanstart.RTTime) != 1) { stop("didn't find the scanstart.RTTime field!"); }
      scanstart.RTTime <- as.numeric(strsplit(scanstart.RTTime, ": ")[[1]][2]);  # take the second part, which should be the number, and check that it really is a number
      if ((scanstart.RTTime > 100) != TRUE) { stop("very short scanstart.RTTime"); }
      edat.tbl <- cbind(edat.tbl, scanstart.RTTime);   # add the scanstart.RTTime column to the output table
      
      # write the finished file to disk and (possibly) upload to box
      write.csv(edat.tbl, paste0(local.fname, "_raw.csv"), row.names=FALSE); # write out as a csv
      
      if (wustl.box == TRUE) {      # running this code at wustl, so upload to box
        do.upload <- TRUE;
        if (reupload == FALSE) {     # need to check if output file already on box, so don't reupload
          f.bs <- box_search(paste0(local.fname, "_raw"), type='file', file_extensions='csv', ancestor_folder_ids=folder.out[[1]]$id);  
          if (length(f.bs) > 0) {   # might be present; check for exact name match 
            for (i in 1:length(f.bs)) {   # i <- 1;
              if (paste0(sub.id, "_", session.ids[ssid], "_", task.ids[tid], sess.ids[ssid], "_run", rid, ".txt_raw.csv") == f.bs[[i]]$name) { 
                do.upload <- FALSE;   # found the match, so set flag not to upload again.
                break;
              }
            }
          }
        }
        
        if (do.upload == TRUE & file.exists(paste0(local.fname, "_raw.csv"))) {    # the csv was written, and we want to upload it
          tmp <- box_ul(dir_id=folder.out[[1]]$id, file=paste0(local.fname, "_raw.csv"));
          if (length(tmp) > 1) { msg <- paste("success: uploaded", tmp$name, "to", tmp$parent$name); }
        }
      }
    } else { msg <- paste("missing:", local.fname); }
    if (wustl.box == TRUE) { rm(boxr.in); }  # clean up environment
  }
  
  return(msg);
} 


# the code below calls the function to actually do the downloading, converting, and uploading for each task and session.
#
# normal behavior:
# if downloading from box, it will print messages as it runs, for example:
# Downloading: 19 kB     [1] "trying to do baseline AXCPT"
# |==========================================================================| 100%
# 
# it will also print multiple copies of this warning, which can be ignored:
# Warning messages:
# 1: partial match of 'cat' to 'category' 
# 2: partial match of 'cat' to 'category' 
#
# if uploading to box, it will print messages such as: 
# success: uploaded 178647_baseline_AxcptBas_run2.txt_raw.csv to AXCPT". 
#
# if everything was uploaded to box successfully, the contents of temp.path can be deleted.


# baseline    
convert.eprime(1, 1);   # Axcpt
convert.eprime(1, 2);   # Cuedts
convert.eprime(1, 3);   # Stern
convert.eprime(1, 4);   # Stroop

# proactive    
convert.eprime(2, 1);   # Axcpt
convert.eprime(2, 2);   # Cuedts
convert.eprime(2, 3);   # Stern
convert.eprime(2, 4);   # Stroop

# reactive    
convert.eprime(3, 1);   # Axcpt
convert.eprime(3, 2);   # Cuedts
convert.eprime(3, 3);   # Stern
convert.eprime(3, 4);   # Stroop


#########################################################################################################################################################
#########################################################################################################################################################
#########################################################################################################################################################
#########################################################################################################################################################
# template code for converting the DMCC out-of-scanner task eprime text recovery files to csv format. 

# note: The DMCC team stores both the input (eprime text recovery files) and output (csv files) in a shared, secure box repository. This function
# thus has flags, so that when it is run by DMCC project team members at Washington University in St. Louis it will automatically download and 
# the files to the proper box location. Since this code is expected to primarily be run by DMCC team members, it defaults to the settings we need.
# To run the code elsewhere (or without automatic box downloading and uploading), set wustl.box <- FALSE; and local input and output directories.

# Whether this code is being run with box at wustl or not, it downloads and writes local copies of the files as it runs. temp.path should be
# set to a directory in which these files can be written. The code will not overwrite files/directories if they already exist, so if it needs
# to be rerun delete any previously-made files (for the particular subject and wave) from temp.path.

rm(list=ls());   # clear R's workspace to start fresh
options(warnPartialMatchDollar=TRUE);   # safety option. boxr functions warn "partial match of 'cat' to 'category'"; disregard. 

# edatparser library functions convert the eprime e-erecovery text files. edatparser is Copyright (c) 2015 Andy Hebrank 
if (require(edatparser) == FALSE) { print("did not find edatparser; please install"); }   # https://github.com/ahebrank/edatparser 


#**** change the lines of code below here ****#

wustl.box <- TRUE;   # if a DMCC team member is running this code (includes automatic download and upload from box)
reupload <- FALSE;   # whether to attempt to reupload files to box, even if already present. ignored if wustl.box == FALSE.
# files not already on box will always be uploaded if wustl.box == TRUE; this is whether to replace ones already present.

sub.id <- "DMCC5244053";   # subject id. (in quotes, even if the subject id is all numbers.)
which.DMCC <- 2;    # which.DMCC <- 3;  # DMCC phase number (e.g. which.DMCC <- 3 for the second wave of scans, DMCC_Phase3)
temp.path <-  "d:/temp/";     # path to a local directory where files will be written out as the code runs.


#**** should not need to change the lines of code below here ****#


task.ids <- c("OSPAN", "SSPAN", "LetterSets", "NumberSeries", "Ravens");   # as named in the directories
short.task.ids <- c("ospan_mod", "sspan_mod", "LetterSets", "NumberSeries", "RAPMOddno");   # as named in the eprime files

if (wustl.box == TRUE) {      # set variables needed to run this code at wustl and interact with box
  if (require(boxr) == FALSE) { print("did not find the boxr library but wustl.box == TRUE"); }   # https://github.com/r-box/boxr
  
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


# make the output directory under temp.path if it doesn't already exist 
out.path <- paste0(temp.path, sub.id);    # NO trailing slash (for box_dl)
if (!dir.exists(out.path)) { dir.create(out.path); }

# this function does the work; it's called from below
convert.eprime <- function(tid) {    # tid <- 1;
  msg <- paste("trying to do", task.ids[tid]);  # start return message string
  
  local.fname <- paste0(out.path, "/", short.task.ids[tid], "-", sub.id, "-1.txt"); 
  if (wustl.box == TRUE) {   # download the file if needed; find the box upload folder 
    if (!file.exists(local.fname)) {       # input file isn't already on disk; so try to download it from box
      folder.in <- box_search(paste0('"', sub.id, '_behavioral_eprime"'), type='folder', ancestor_folder_ids=ancestor.raw);  # in from Raw_Data
      if (length(folder.in) != 1) { stop("didn't find the input folder on box?"); }
      
      fname <- paste0('"', short.task.ids[tid], "-", sub.id, "-1", '"');   # name on box
      boxr.in <- box_search(fname, type='file', content_types="name", file_extensions='txt', ancestor_folder_ids=folder.in[[1]]$id);  # search for the file on box.com
      if (length(boxr.in) == 1) { box_dl(boxr.in[[1]]$id, local_dir=out.path); }    # found the right file, so download
      rm(boxr.in);   # clean up 
    }
    
    # will output to the person's behavioral_eprime under Preprocessed Data, so find it.
    folder.out1 <- box_search(paste0('"', sub.id, '"'), type='folder', ancestor_folder_ids=ancestor.prep);   # find the subject's Preprocessed Data folder 
    if (length(folder.out1) == 1) {
      folder.out <- box_search('"behavioral_eprime"', type='folder', ancestor_folder_ids=folder.out1[[1]]$id);  # and behavioral_eprime subdirectory
    } else { stop("didn't find the subject's output folder on box?"); }
    if (length(folder.out) == 0) { stop("didn't find the behavioral_eprime folder on box?"); }
  }
  
  # should now have the file locally. if so, rearrange to a matrix and write as a csv.
  if (file.exists(local.fname)) {     
    if (R.version$major < 4) {      # version 4 of R requires a more complex procedure than previous, so check version first.
      edat.tbl <- as.data.frame(edat(local.fname));     # read in the erecovery text file and convert to a data.frame
    } else {    # version 4.0.0 and beyond
      edat.list <- edat(local.fname);   # read in the erecovery text file
      
      # all of the needed values are in edat.list$trial_info, but each entry only has columns the row has values for, so can't just read it in.
      trial.list <- edat.list$trial_info;
      
      # collect all the trial names.
      all.names <- names(trial.list[[1]]);   # start with the first row
      for (i in 2:length(trial.list)) { all.names <- union(all.names, names(trial.list[[i]])); }  # union the rest for a non-repeating set
      
      # now know the size of the output table needed, so make it and fill it up.
      edat.tbl <- data.frame(array(NA, c(length(trial.list), length(all.names))));
      colnames(edat.tbl) <- all.names;  
      for (i in 1:length(trial.list)) {   # i <- 1;
        this.row <- trial.list[[i]];
        for (j in 1:length(this.row)) {   # j <- 1;
          edat.tbl[i,names(this.row)[j]] <- this.row[j];
        }
      }
    }
    
    # write the finished file to disk and (possibly) upload to box
    write.csv(edat.tbl, paste0(local.fname, "_raw.csv"), row.names=FALSE); # write out as a csv
    
    if (wustl.box == TRUE) {      # running this code at wustl, so upload to box
      do.upload <- TRUE;
      if (reupload == FALSE) {     # need to check if output file already on box, so don't reupload
        f.bs <- box_search(paste0(local.fname, "_raw"), type='file', file_extensions='csv', ancestor_folder_ids=folder.out[[1]]$id);  
        if (length(f.bs) > 0) {   # might be present; check for exact name match 
          for (i in 1:length(f.bs)) {   # i <- 1;
            if (paste0(short.task.ids[tid], "-", sub.id, "-1.txt_raw.csv") == f.bs[[i]]$name) { 
              do.upload <- FALSE;   # found the match, so set flag not to upload again.
              break;
            }
          }
        }
      }
      
      if (do.upload == TRUE & file.exists(paste0(local.fname, "_raw.csv"))) {    # the csv was written, and we want to upload it
        tmp <- box_ul(dir_id=folder.out[[1]]$id, file=paste0(local.fname, "_raw.csv"));
        if (length(tmp) > 1) { msg <- paste("success: uploaded", tmp$name, "to", tmp$parent$name); }
      }
    }
  } else { msg <- paste("missing:", local.fname); }
  
  return(msg);
} 


# the code below calls the function to actually do the downloading, converting, and uploading for each questionnaire.
#
# normal behavior:
# if downloading from box, it will print messages as it runs, for example:
# [1] "trying to do LetterSets"
# |==========================================================================| 100%
# 
# it will also print multiple copies of this warning, which can be ignored:
# Warning messages:
# partial match of 'cat' to 'category' 
#
# if uploading to box, it will print messages such as: 
# success: uploaded NumberSeries-DMCC5244053-1.txt_raw.csv to behavioral_eprime". 
#
# if everything was uploaded to box successfully, the contents of temp.path can be deleted.

convert.eprime(1);   # OSPAN 
convert.eprime(2);   # SSPAN
convert.eprime(3);   # LetterSets
convert.eprime(4);   # NumberSeries
convert.eprime(5);   # Ravens

#########################################################################################################################################################
#########################################################################################################################################################
#########################################################################################################################################################
