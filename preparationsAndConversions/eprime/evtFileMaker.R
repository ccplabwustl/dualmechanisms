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

# Source this file from TEMPLATE_createEVTs.R, don't use directly.

#########################################################################################################################################################
#########################################################################################################################################################

# variables for all sessions
session.ids <- c("baseline", "proactive", "reactive");
sess.ids <- c("Bas", "Pro", "Rea");  # shorter version of the session.ids; same order as session.ids
run.ids <- c(1, 2);   # AP and PA runs for each task and session

# variables for AX-CPT
axcpt.ids <- c("AX", "AY", "BX", "BY", "Ang", "Bng");   # as coded in $TrialType
axcpt.ids.ct <- c(24,6,6,24,6,6);  # number of trials of each type in each run, in order axcpt.ids; same in both runs, all sessions

# variables for CuedTS
cuedts.ids.in <- c("Attend Letter", "Attend Number");   # as coded in $TaskCue
cuedts.ids.out <- c("letter", "number");   # shorter versions for the output files; same order as cuedts.ids.in
task.cts.cued <- rbind(c(27,27), c(27,27));  # number of trials of each type in each run, in order axcpt.ids; 1st row run 1, 2nd row run 2
inc.ids.in <- c("NonIncentive", "Incentive");   # as coded in $TrialType
inc.ids.out <- c("NoInc", "Inc");  
inc.colors <- c("Black", "Green");   # NoInc, Inc (like inc.ids.in), as coded in ColorOrig 
switch.ids.in <- c(0, 1);    # as coded in $n_switch
switch.ids.out <- c("Repeat", "Switch");   # labels for the evt files; same order as switch.ids.in

# variables for Sternberg
list.lengths <- 2:8;
need.cts <- rbind(c(14,9,4,18,4,9,14), c(13,9,5,18,5,9,13));  # number of trials at each list length in each run, in order list.lengths; 1st row run 1, 2nd row run 2
tt.ids <- c("NN", "NP", "RN");   # TrialType column 

# variables for Stroop
con.ids.in <- c("Congruent", "Incongruent");   # as coded in $Congruency
con.ids.out <- c("Con", "InCon");
con.ids.cts <- rbind(c(35,19), c(35,19));  # number of trials of each type in each run, in order con.ids; 1st row run 1, 2nd row run 2

###########################    AX-CPT    ##########################
do.Axcpt <- function(sub.id, which.DMCC, use.runs) {     
  # sub.id <- "130114"; which.DMCC <- 2; use.runs<-c("Bas1", "Bas2", "Pro1", "Pro2", "Rea1", "Rea2");  # use.runs <- c("Bas1", NA, "Pro1", "Pro2", "Rea1", "Rea2");
  error.str <- "";   # empty string for returning error messages
  
  # build a list of the input eprime files, into the all.ins object so they only need to be read in once.
  # adapted from \R01\Jo\for800msecTR\knitr\singleSubSummary\singleSubSummary.rnw
  all.ins <- list(Bas1=NA, Bas2=NA, Pro1=NA, Pro2=NA, Rea1=NA, Rea2=NA);
  for (ssid in 1:length(session.ids)) {
    for (rid in 1:2) {     # ssid <- 1; rid <- 1;
      if (length(which(use.runs == paste0(sess.ids[ssid], rid))) == 1) {   # run should be good (listed in use.runs)
        if (wustl.box == TRUE) {
          if (exists('in.tbl')) { rm(in.tbl); }   # clean up
          fname <- paste0('"', sub.id, "_", session.ids[ssid], "_Axcpt", sess.ids[ssid], "_run", rid, '.txt_raw"'); 
          tmp <- box_search(fname, type='file', file_extensions='csv', ancestor_folder_ids=folder.num); 
          if (length(tmp) == 0) { 
            error.str <- c(error.str, paste("missing:", fname)); 
          } else {
            if (length(tmp) == 1) { in.tbl <- box_read_csv(tmp[[1]]$id); }
            if (length(tmp) > 1) {   # probably have a case of DMCC and HCP IDs sharing the number part of the names
              use.index <- 0;
              for (i in 1:length(tmp)) {   # i <- 1;
                if (tmp[[i]]$name == fname) { use.index <- i; }   # found the matching entry
              }
              if (use.index == 0) { error.str <- c(error.str, paste("missing:", fname)); }
              in.tbl <- box_read_csv(tmp[[use.index]]$id);
            }
            # convert from box version
            in.tbl$CueSlide.OnsetTime <- as.numeric(in.tbl$CueSlide.OnsetTime);
            in.tbl$CueSlide.RTTime <- as.numeric(in.tbl$CueSlide.RTTime);
            in.tbl$Flicker.OnsetTime <- as.numeric(in.tbl$Flicker.OnsetTime);
            in.tbl$ProbeSlide.OffsetTime <- as.numeric(in.tbl$ProbeSlide.OffsetTime);
            in.tbl$ProbeSlide.RTTime <- as.numeric(in.tbl$ProbeSlide.RTTime);
            in.tbl$Fixation.OnsetTime <- as.numeric(in.tbl$Fixation.OnsetTime);
            in.tbl$FixationFinal.OnsetTime <- as.numeric(in.tbl$FixationFinal.OnsetTime);
            in.tbl$getready.OnsetTime <- as.numeric(in.tbl$getready.OnsetTime);
            
            all.ins[[paste0(sess.ids[ssid], rid)]] <- in.tbl;  # store in all-sessions-and-runs object
          } 
        } else {
          fname <- paste0(in.path, sub.id, "_", session.ids[ssid], "_Axcpt", sess.ids[ssid], "_run", rid, ".txt_raw.csv"); 
          if (file.exists(fname)) { 
            in.tbl <- read.csv(fname); 
            all.ins[[paste0(sess.ids[ssid], rid)]] <- in.tbl; 
          } else { error.str <- c(error.str, paste("missing:", fname)); }
        }
      }
    }
  }
  
  
  # make the task onset files: each trial type separately, starting at CueSlide.OnsetTime
  for (i in 1:length(axcpt.ids)) {   # need one onset file for each $TrialType (all three sessions)    # i <- 1;
    for (ssid in 1:length(session.ids)) {       # ssid <- 1; i <- 1;
      fout <- file(paste0(out.path, sub.id, "_Axcpt_", session.ids[ssid], "_", axcpt.ids[i], ".txt"), 'wt');  # start an empty file for the onsets
      for (rid in 1:length(run.ids)) {    # rid <- 1;
        if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
          in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
          if (length(which(in.tbl$Procedure == "AXCPTTrialPROC")) != 72) { stop(paste("not 72 trials:", fname)); }  # error-checking
          start.value <- in.tbl$scanstart.RTTime[1];         # value which needs to be subtracted from all events onsets for the true onsets.
          if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }          
          inds <- which(in.tbl$TrialType == axcpt.ids[i]);
          if (length(inds) != axcpt.ids.ct[i]) { stop(paste("not right number of", axcpt.ids[i], "trials.", fname)); } 
          onsets <- (in.tbl$CueSlide.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
          
          onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
          cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
        } else { 
          cat("*\n", file=fout);     # add to the file with onsets for just this session
        }
      }
      close(fout); unlink(fout);     # close the file we just wrote for this session
    }
  }  
  
  
  # allTrials; starting at CueSlide.OnsetTime
  for (ssid in 1:length(session.ids)) {       # ssid <- 1;
    fout <- file(paste0(out.path, sub.id, "_Axcpt_", session.ids[ssid], "_allTrials.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];        # value which needs to be subtracted from all events onsets for the true onsets.
        inds <- which(in.tbl$TrialType == "AX" | in.tbl$TrialType == "AY" | in.tbl$TrialType == "BX" | in.tbl$TrialType == "BY" | 
                        in.tbl$TrialType == "Ang" | in.tbl$TrialType == "Bng");
        if (length(inds) != 72) { stop(paste("not 72 AXAYAngBXBYBng trials.", fname)); } 
        onsets <- (in.tbl$CueSlide.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else { 
        cat("*\n", file=fout);     # add to the file with onsets for just this session
      }  
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session
  }
  
  
  # block onset AND offset times;
  # start the blocks at $Procedure == FixationGetReadyPROC, $getready.OnsetTime; end at $Procedure == FixationGetReadyPROC, $getready.OnsetTime
  for (ssid in 1:length(session.ids)) {   # ssid <- 1;
    fout <- file(paste0(out.path, sub.id, "_Axcpt_", session.ids[ssid], "_blockONandOFF.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];    
        inds <- which(in.tbl$Procedure == "FixationGetReadyPROC");   # same as above: block onsets
        if (length(inds) != 3) { stop(paste("not 3 FixationGetReadyPROC:", fname)); } 
        onsets <- (in.tbl$getready.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
        offset.1 <- (in.tbl$Fixation.OnsetTime[inds[2]] - start.value)/1000;
        offset.2 <- (in.tbl$Fixation.OnsetTime[inds[3]] - start.value)/1000;
        offset.3 <- (in.tbl$FixationFinal.OnsetTime[which(in.tbl$Procedure == "FixationOnlyPROC")] - start.value)/1000; # last coded differently
        onsets <- sort(c(onsets, offset.1, offset.2, offset.3));  # sort so onsets and offsets nicely arranged
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else { cat("*\n", file=fout); }    # add to the file
    }
    close(fout); unlink(fout);
  }
  
  
  # make the block timing files: start the blocks at onset of first trial in block; duration until start of last trial in block.
  for (ssid in 1:length(session.ids)) {   # ssid <- 1;
    fout <- file(paste0(out.path, sub.id, "_Axcpt_", session.ids[ssid], "_block.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];         # value which needs to be subtracted from all events onsets for the true onsets.
        if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }          
        inds <- which(in.tbl$Procedure == "FixationGetReadyPROC");   # line before each block
        if (length(which(in.tbl$Procedure[inds+1] == "AXCPTTrialPROC")) != 3) { stop(paste("not expected row ordering", fname)); }
        if (in.tbl$Procedure[inds[2]-1] != "AXCPTTrialPROC" | in.tbl$Procedure[inds[3]-1] != "AXCPTTrialPROC") { stop(paste("not expected row ordering", fname)); }
        
        # find the first and last trial of each block, by looking relative to the FixationGetReadyPROC inds (which mark start of each block)
        onsets <- (in.tbl$CueSlide.OnsetTime[inds+1] - start.value)/1000;  # inds+1 to get first TRIAL of each block
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        
        offset.1 <- (in.tbl$CueSlide.OnsetTime[inds[2]-1] - start.value)/1000;   # end of first block, in s
        offset.2 <- (in.tbl$CueSlide.OnsetTime[inds[3]-1] - start.value)/1000;
        offset.3 <- (in.tbl$CueSlide.OnsetTime[which(in.tbl$Procedure == "FixationOnlyPROC")-1] - start.value)/1000;  # last block, look for final fixation
        offset.1 <- offset.1 - (offset.1 %% 1.2);   # shift to closest previous TR.
        offset.2 <- offset.2 - (offset.2 %% 1.2); 
        offset.3 <- offset.3 - (offset.3 %% 1.2); 
        
        if (onsets[2]-offset.1 < 30 | onsets[3]-offset.2 < 30 | onsets[1] < 30) { stop(paste("breaks too short:", fname)); }
        # duration of each block is offset - onset
        cat(paste0(onsets[1], ":", (offset.1-onsets[1]), " ", onsets[2], ":", (offset.2-onsets[2]), " ", onsets[3], ":", (offset.3-onsets[3]), "\n"), file=fout);   
      } else { 
        cat("*\n", file=fout);     # * if run missing
      } 
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session and type
  }
  
  
  # make the buttons output files. button is coded as 1 or 2 in TargetSlide.RESP
  for (button in 1:2) {  # button <- 1;
    for (ssid in 1:length(session.ids)) {   # ssid <- 1;
      fout <- file(paste0(out.path, sub.id, "_Axcpt_", session.ids[ssid], "_button", button, ".txt"), 'wt');  # start an empty file for the onsets
      for (rid in 1:length(run.ids)) {    # rid <- 1;
        if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
          in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
          start.value <- in.tbl$scanstart.RTTime[1];         # value which needs to be subtracted from all events onsets for the true onsets.
          if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }          
          inds <- which(in.tbl$ProbeSlide.RESP == button);   # probe slide button pushes
          onsets.P <- (in.tbl$ProbeSlide.RTTime[inds] - start.value)/1000;  # time button was pushed; /1000 to convert to seconds
          inds <- which(in.tbl$CueSlide.RESP == button);   # cue slide button pushes
          if (length(inds) > 0) {   # cue slide should only have one button pushed, so check.
            onsets.C <- (in.tbl$CueSlide.RTTime[inds] - start.value)/1000;  # time button was pushed; /1000 to convert to seconds
            onsets <- sort(c(onsets.P, onsets.C));  # all button-pushes
          } else { onsets <- onsets.P; }
          if (length(onsets) > 0) {
            onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
            cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
          } else {
            cat("*\n", file=fout);     # add to the file with onsets for just this session
            error.str <- c(error.str, paste("no button pushes:", fname));
          }         
        } else { 
          cat("*\n", file=fout);     # add to the file with onsets for just this session
        }  
      }
      close(fout); unlink(fout);     # close the file we just wrote for this session and type
    }
  }
  
  return(list(err.str=error.str, eprimes=all.ins));
}


###########################    CuedTS    ##########################
do.Cuedts <- function(sub.id, which.DMCC, use.runs) {     
  # sub.id <- "130114"; which.DMCC <- 2; use.runs <- c("Bas1", NA, "Pro1", "Pro2", "Rea1", "Rea2");
  error.str <- "";   # empty string for returning error messages
  
  # build a list of the input eprime files, into the all.ins object so they only need to be read in once.
  # same as in "D:\gitFiles_ccplabwustl\R01\Jo\for800msecTR\knitr\singleSubSummary\singleSubSummary.rnw"
  all.ins <- list(Bas1=NA, Bas2=NA, Pro1=NA, Pro2=NA, Rea1=NA, Rea2=NA);
  for (ssid in 1:length(session.ids)) {
    for (rid in 1:2) {     # ssid <- 3; rid <- 1;
      if (length(which(use.runs == paste0(sess.ids[ssid], rid))) == 1) {   # run should be good (listed in use.runs)
        if (wustl.box == TRUE) {
          fname <- paste0('"', sub.id, "_", session.ids[ssid], "_Cuedts", sess.ids[ssid], "_run", rid, '.txt_raw"'); 
          tmp <- box_search(fname, type='file', file_extensions='csv', ancestor_folder_ids=folder.num); 
          if (length(tmp) == 1) { 
            in.tbl <- box_read_csv(tmp[[1]]$id);  
            in.tbl$Flicker.OnsetTime <- as.numeric(in.tbl$Flicker.OnsetTime);
            in.tbl$Fixation.OnsetTime <- as.numeric(in.tbl$Fixation.OnsetTime);
            in.tbl$FixationFinal.OnsetTime <- as.numeric(in.tbl$FixationFinal.OnsetTime);
            in.tbl$CueSlide.OnsetTime <- as.numeric(in.tbl$CueSlide.OnsetTime);
            in.tbl$TargetSlide.RTTime <- as.numeric(in.tbl$TargetSlide.RTTime);
            in.tbl$TargetSlide.ACC <- as.numeric(in.tbl$TargetSlide.ACC);
            in.tbl$TargetSlide.RT <- as.numeric(in.tbl$TargetSlide.RT);
            in.tbl$getready.OnsetTime <- as.numeric(in.tbl$getready.OnsetTime);
            
            all.ins[[paste0(sess.ids[ssid], rid)]] <- in.tbl;
          } 
          if (length(tmp) == 0) { error.str <- c(error.str, paste("missing:", fname)); }
          if (length(tmp) > 1) { error.str <- c(error.str, paste("found > 1 file named", fname)); }
        } else {
          fname <- paste0(in.path, sub.id, "_", session.ids[ssid], "_Cuedts", sess.ids[ssid], "_run", rid, ".txt_raw.csv"); 
          if (file.exists(fname)) { 
            in.tbl <- read.csv(fname); 
            all.ins[[paste0(sess.ids[ssid], rid)]] <- in.tbl; 
          } else { error.str <- c(error.str, paste("missing:", fname)); }
        }
      }
    }
  }
  
  # make the allTrials onset files
  for (ssid in 1:length(session.ids)) {       # ssid <- 1;
    fout <- file(paste0(out.path, sub.id, "_Cuedts_", session.ids[ssid], "_allTrials.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        # set the start value which needs to be subtracted from all events onsets to obtain the true onsets.
        start.value <- in.tbl$scanstart.RTTime[1];
        if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
        inds <- which(in.tbl$TaskCue == "Attend Letter" | in.tbl$TaskCue == "Attend Number");
        onsets <- (in.tbl$CueSlide.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else {
        cat("*\n", file=fout);     # add to the file with onsets for just this session
      }
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session
  }
  
  
  # make the onset files for the CongruencyIncentive GLM: ConInc, ConNoInc, InConInc, InConNoInc, starting at CueSlide.OnsetTime
  for (i in 1:length(con.ids.in)) {   # need one onset file for each $Congruency (all three sessions)    # i <- 1;
    for (iid in 1:length(inc.ids.in)) {      # i <- 1; iid <- 1;
      for (ssid in 1:length(session.ids)) {       # ssid <- 1;
        fout <- file(paste0(out.path, sub.id, "_Cuedts_", session.ids[ssid], "_", con.ids.out[i], inc.ids.out[iid], ".txt"), 'wt');  # start an empty file for the onsets
        for (rid in 1:length(run.ids)) {    # rid <- 1;
          if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
            in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
            start.value <- in.tbl$scanstart.RTTime[1];   # value which needs to be subtracted from all events onsets for the true onsets.
            if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
            inds <- which(in.tbl$Congruency == con.ids.in[i] & in.tbl$ColorOrig == inc.colors[iid]);  # both congruency AND incentive
            #if (length(inds) != con.ids.cts[rid,i]) { stop(paste("not right number of", con.ids.in[i], "trials.", fname)); }
            onsets <- (in.tbl$CueSlide.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
            onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
            cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
          } else {
            cat("*\n", file=fout);     # add to the file with onsets for just this session
          }
        }
        close(fout); unlink(fout);     # close the file we just wrote for this session
      }
    }
  }
  
  
  # make the onset files for the SwitchIncentive GLM: SwitchInc, SwitchNoInc, RepeatInc, RepeatNoInc, starting at CueSlide.OnsetTime
  for (i in 1:length(switch.ids.in)) {   # need one onset file for each $n_Switch (all three sessions)    # i <- 1;
    for (iid in 1:length(inc.ids.in)) {      # i <- 1; iid <- 1;
      for (ssid in 1:length(session.ids)) {       # ssid <- 1;
        fout <- file(paste0(out.path, sub.id, "_Cuedts_", session.ids[ssid], "_", switch.ids.out[i], inc.ids.out[iid], ".txt"), 'wt');  # start an empty file for the onsets
        for (rid in 1:length(run.ids)) {    # rid <- 1;
          if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
            in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
            start.value <- in.tbl$scanstart.RTTime[1];   # value which needs to be subtracted from all events onsets for the true onsets.
            if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
            inds <- which(in.tbl$n_Switch == switch.ids.in[i] & in.tbl$ColorOrig == inc.colors[iid]);  # both switch AND incentive
            onsets <- (in.tbl$CueSlide.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
            onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
            cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
          } else {
            cat("*\n", file=fout);     # add to the file with onsets for just this session
          }
        }
        close(fout); unlink(fout);     # close the file we just wrote for this session
      }
    }
  }
  
  
  # make the onset files for the Incentive GLM: Inc, NoInc, starting at CueSlide.OnsetTime
  for (iid in 1:length(inc.ids.in)) {      # iid <- 1;
    for (ssid in 1:length(session.ids)) {       # ssid <- 1;
      fout <- file(paste0(out.path, sub.id, "_Cuedts_", session.ids[ssid], "_", inc.ids.out[iid], ".txt"), 'wt');  # start an empty file for the onsets
      for (rid in 1:length(run.ids)) {    # rid <- 1;
        if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
          in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
          start.value <- in.tbl$scanstart.RTTime[1];   # value which needs to be subtracted from all events onsets for the true onsets.
          if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
          inds <- which(in.tbl$ColorOrig == inc.colors[iid]);  # just incentive
          onsets <- (in.tbl$CueSlide.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
          onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
          cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
        } else {
          cat("*\n", file=fout);     # add to the file with onsets for just this session
        }
      }
      close(fout); unlink(fout);     # close the file we just wrote for this session
    }
  }
  
  
  # make the onset files for the LetterNumber GLM: attend letter or attend number, starting at CueSlide$OnsetTime
  for (i in 1:length(cuedts.ids.in)) {   # need one onset file for each $TaskCue (all three sessions)    # i <- 1;
    for (ssid in 1:length(session.ids)) {       # ssid <- 1;
      fout <- file(paste0(out.path, sub.id, "_Cuedts_", session.ids[ssid], "_", cuedts.ids.out[i], ".txt"), 'wt');  # start an empty file for the onsets
      for (rid in 1:length(run.ids)) {    # rid <- 1;
        if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
          in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
          if (length(which(in.tbl$Procedure == "CuedTSTrialPROC")) != 54) { stop(paste("not 54 trials:", fname)); }  # error-checking
          start.value <- in.tbl$scanstart.RTTime[1];   # value which needs to be subtracted from all events onsets for the true onsets.
          if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
          inds <- which(in.tbl$TaskCue == cuedts.ids.in[i]);
          if (length(inds) != task.cts.cued[rid,i]) { stop(paste("not right number of", cuedts.ids.in[i], "trials.", fname)); }
          onsets <- (in.tbl$CueSlide.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
          onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
          cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
        } else {
          cat("*\n", file=fout);     # add to the file with onsets for just this session
        }
      }
      close(fout); unlink(fout);     # close the file we just wrote for this session
    }
  }
  
  
  # block onset AND offset times; end the blocks at $Procedure == FixationGetReadyPROC, $getready.OnsetTime
  for (ssid in 1:length(session.ids)) {   # ssid <- 1;
    fout <- file(paste0(out.path, sub.id, "_Cuedts_", session.ids[ssid], "_blockONandOFF.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];
        inds <- which(in.tbl$Procedure == "FixationGetReadyPROC");   # same as above: block onsets
        if (length(inds) != 3) { stop(paste("not 3 FixationGetReadyPROC:", fname)); }
        onsets <- (in.tbl$getready.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
        offset.1 <- (in.tbl$Fixation.OnsetTime[inds[2]] - start.value)/1000;
        offset.2 <- (in.tbl$Fixation.OnsetTime[inds[3]] - start.value)/1000;
        offset.3 <- (in.tbl$FixationFinal.OnsetTime[which(in.tbl$Procedure == "FixationOnlyPROC")] - start.value)/1000; # last coded differently
        
        onsets <- sort(c(onsets, offset.1, offset.2, offset.3));  # sort so onsets and offsets nicely arranged
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else { cat("*\n", file=fout); }    # add to the file
    }
    close(fout); unlink(fout);
  }
  
  
  # make the block timing files: start the blocks at onset of first trial in block; duration until start of last trial in block.
  for (ssid in 1:length(session.ids)) {   # ssid <- 1;
    fout <- file(paste0(out.path, sub.id, "_Cuedts_", session.ids[ssid], "_block.txt"), 'wt'); 
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];         # value which needs to be subtracted from all events onsets for the true onsets.
        if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }          
        inds <- which(in.tbl$Procedure == "FixationGetReadyPROC");   # line before each block
        if (length(which(in.tbl$Procedure[inds+1] == "CuedTSTrialPROC")) != 3) { stop(paste("not expected row ordering", fname)); }
        if (in.tbl$Procedure[inds[2]-1] != "CuedTSTrialPROC" | in.tbl$Procedure[inds[3]-1] != "CuedTSTrialPROC") { stop(paste("not expected row ordering", fname)); }
        
        # find the first and last trial of each block, by looking relative to the FixationGetReadyPROC inds (which mark start of each block)
        onsets <- (in.tbl$CueSlide.OnsetTime[inds+1] - start.value)/1000;  # inds+1 to get first TRIAL of each block
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        
        offset.1 <- (in.tbl$CueSlide.OnsetTime[inds[2]-1] - start.value)/1000;   # end of first block, in s
        offset.2 <- (in.tbl$CueSlide.OnsetTime[inds[3]-1] - start.value)/1000;
        offset.3 <- (in.tbl$CueSlide.OnsetTime[which(in.tbl$Procedure == "FixationOnlyPROC")-1] - start.value)/1000;  # last block, look for final fixation
        offset.1 <- offset.1 - (offset.1 %% 1.2);   # shift to closest previous TR.
        offset.2 <- offset.2 - (offset.2 %% 1.2); 
        offset.3 <- offset.3 - (offset.3 %% 1.2); 
        
        if (onsets[2]-offset.1 < 30 | onsets[3]-offset.2 < 30 | onsets[1] < 30) { stop(paste("breaks too short:", fname)); }
        # duration of each block is offset - onset
        cat(paste0(onsets[1], ":", (offset.1-onsets[1]), " ", onsets[2], ":", (offset.2-onsets[2]), " ", onsets[3], ":", (offset.3-onsets[3]), "\n"), file=fout);   
      } else { 
        cat("*\n", file=fout);     # * if run missing
      } 
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session and type
  }
  
  
  # make the buttons output files. button is coded as 1 or 2 in TargetSlide.RESP
  for (button in 1:2) {  # button <- 1;
    for (ssid in 1:length(session.ids)) {   # ssid <- 1;
      fout <- file(paste0(out.path, sub.id, "_Cuedts_", session.ids[ssid], "_button", button, ".txt"), 'wt');  # start an empty file for the onsets
      for (rid in 1:length(run.ids)) {    # rid <- 1;
        if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
          in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
          start.value <- in.tbl$scanstart.RTTime[1];   # value which needs to be subtracted from all events onsets for the true onsets.
          if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
          inds <- which(in.tbl$TargetSlide.RESP == button);   # this isn't looking for NAs, accuracy, etc: just the actual button pushes
          onsets <- (in.tbl$TargetSlide.RTTime[inds] - start.value)/1000;  # time button was pushed; /1000 to convert to seconds
          if (length(onsets) > 0) {
            onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
            cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
          } else {
            cat("*\n", file=fout);     # add to the file with onsets for just this session
            error.str <- c(error.str, paste("no button pushes:", fname));
          }
        } else {
          cat("*\n", file=fout);     # add to the file with onsets for just this session
        }
      }
      close(fout); unlink(fout);     # close the file we just wrote for this session and type
    }
  }
  
  return(list(err.str=error.str, eprimes=all.ins));
}

# ###########################   Sternberg  ##########################
do.Stern <- function(sub.id, which.DMCC, use.runs) {     
  # sub.id <- "130114"; which.DMCC <- 2;  use.runs <- c("Bas1", NA, "Pro1", "Pro2", "Rea1", "Rea2");
  error.str <- "";   # empty string for returning error messages
  
  # build a list of the input eprime files, into the all.ins object so they only need to be read in once.
  # same as in "D:\gitFiles_ccplabwustl\R01\Jo\for800msecTR\knitr\singleSubSummary\singleSubSummary.rnw"
  all.ins <- list(Bas1=NA, Bas2=NA, Pro1=NA, Pro2=NA, Rea1=NA, Rea2=NA);
  for (ssid in 1:length(session.ids)) {
    for (rid in 1:2) {     # ssid <- 3; rid <- 1;
      if (length(which(use.runs == paste0(sess.ids[ssid], rid))) == 1) {   # run should be good (listed in use.runs)
        if (wustl.box == TRUE) {
          fname <- paste0('"', sub.id, "_", session.ids[ssid], "_Stern", sess.ids[ssid], "_run", rid, '.txt_raw"'); 
          tmp <- box_search(fname, type='file', file_extensions='csv', ancestor_folder_ids=folder.num); 
          if (length(tmp) == 1) { 
            in.tbl <- box_read_csv(tmp[[1]]$id);  
            in.tbl$Flicker.OnsetTime <- as.numeric(in.tbl$Flicker.OnsetTime);
            in.tbl$ListLen <- as.numeric(in.tbl$ListLen);
            in.tbl$ProbeSlide.ACC <- as.numeric(in.tbl$ProbeSlide.ACC);
            in.tbl$ProbeSlide.RT <- as.numeric(in.tbl$ProbeSlide.RT);
            in.tbl$ProbeSlide.RTTime <- as.numeric(in.tbl$ProbeSlide.RTTime);
            in.tbl$ProbeSlide.RESP <- as.numeric(in.tbl$ProbeSlide.RESP);
            in.tbl$List1Slide.OnsetTime <- as.numeric(in.tbl$List1Slide.OnsetTime);
            in.tbl$Fixation.OnsetTime <- as.numeric(in.tbl$Fixation.OnsetTime);
            in.tbl$FixationFinal.OnsetTime <- as.numeric(in.tbl$FixationFinal.OnsetTime);
            in.tbl$getready.OnsetTime <- as.numeric(in.tbl$getready.OnsetTime);
            
            all.ins[[paste0(sess.ids[ssid], rid)]] <- in.tbl;
          } 
          if (length(tmp) == 0) { error.str <- c(error.str, paste("missing:", fname)); }
          if (length(tmp) > 1) { error.str <- c(error.str, paste("found > 1 file named", fname)); }
        } else {
          fname <- paste0(in.path, sub.id, "_", session.ids[ssid], "_Stern", sess.ids[ssid], "_run", rid, ".txt_raw.csv"); 
          if (file.exists(fname)) { 
            in.tbl <- read.csv(fname, stringsAsFactors=FALSE); 
            all.ins[[paste0(sess.ids[ssid], rid)]] <- in.tbl; 
          } else { error.str <- c(error.str, paste("missing:", fname)); }
        }
      }
    }
  }
  
  # allTrials
  for (ssid in 1:length(session.ids)) {       # ssid <- 2;
    fout <- file(paste0(out.path, sub.id, "_Stern_", session.ids[ssid], "_allTrials.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];      # value which needs to be subtracted from all events onsets to obtain the true onsets.
        if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
        inds <- which(!is.na(in.tbl$ListLen));
        onsets <- (in.tbl$List1Slide.OnsetTime[inds] - start.value)/1000;  # /1000 to convert to seconds
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else {
        cat("*\n", file=fout);     # add to the file with onsets for just this session
      }
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session
  }
  
  
  # LL5 or not, all TrialTypes; LL2LL3LL4 for proactive, LL6LL7LL8 for baseline and reactive
  for (ssid in 1:length(session.ids)) {       # ssid <- 2;
    fout <- file(paste0(out.path, sub.id, "_Stern_", session.ids[ssid], "_LL5.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];      # value which needs to be subtracted from all events onsets to obtain the true onsets.
        if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
        inds <- which(in.tbl$ListLen == 5);  # list length 5, all TrialTypes
        onsets <- (in.tbl$List1Slide.OnsetTime[inds] - start.value)/1000;  # /1000 to convert to seconds
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else {
        cat("*\n", file=fout);     # add to the file with onsets for just this session
      }
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session
  }
  
  for (ssid in 1:length(session.ids)) {       # ssid <- 2;
    fout <- file(paste0(out.path, sub.id, "_Stern_", session.ids[ssid], "_not5.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];      # value which needs to be subtracted from all events onsets to obtain the true onsets.
        if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
        inds <- which(in.tbl$ListLen != 5);  # not list length 5, all TrialTypes
        onsets <- (in.tbl$List1Slide.OnsetTime[inds] - start.value)/1000;  # /1000 to convert to seconds
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else {
        cat("*\n", file=fout);     # add to the file with onsets for just this session
      }
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session
  }
  
  
  # LL5 or not, each TrialType separately.
  for (ttid in 1:length(tt.ids)) {
    for (ssid in 1:length(session.ids)) {       # ssid <- 2;
      fout <- file(paste0(out.path, sub.id, "_Stern_", session.ids[ssid], "_LL5", tt.ids[ttid], ".txt"), 'wt');  # start an empty file for the onsets
      for (rid in 1:length(run.ids)) {    # rid <- 1;
        if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
          in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
          start.value <- in.tbl$scanstart.RTTime[1];      # value which needs to be subtracted from all events onsets to obtain the true onsets.
          if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
          inds <- which(in.tbl$ListLen == 5 & in.tbl$TrialType == tt.ids[ttid]);  # list length 5, TrialType ttid
          onsets <- (in.tbl$List1Slide.OnsetTime[inds] - start.value)/1000;  # /1000 to convert to seconds
          onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
          cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
        } else {
          cat("*\n", file=fout);     # add to the file with onsets for just this session
        }
      }
      close(fout); unlink(fout);     # close the file we just wrote for this session
    }
    
    for (ssid in 1:length(session.ids)) {       # ssid <- 2;
      fout <- file(paste0(out.path, sub.id, "_Stern_", session.ids[ssid], "_not5", tt.ids[ttid], ".txt"), 'wt');  # start an empty file for the onsets
      for (rid in 1:length(run.ids)) {    # rid <- 1;
        if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
          in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
          start.value <- in.tbl$scanstart.RTTime[1];      # value which needs to be subtracted from all events onsets to obtain the true onsets.
          if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
          inds <- which(in.tbl$ListLen != 5 & in.tbl$TrialType == tt.ids[ttid]);  # not list length 5, TrialType ttid
          onsets <- (in.tbl$List1Slide.OnsetTime[inds] - start.value)/1000;  # /1000 to convert to seconds
          cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
        } else {
          cat("*\n", file=fout);     # add to the file with onsets for just this session
        }
      }
      close(fout); unlink(fout);     # close the file we just wrote for this session
    }
    
    for (ssid in 1:length(session.ids)) {       # ssid <- 2;
      fout <- file(paste0(out.path, sub.id, "_Stern_", session.ids[ssid], "_", tt.ids[ttid], ".txt"), 'wt');  # start an empty file for the onsets
      for (rid in 1:length(run.ids)) {    # rid <- 1;
        if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
          in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
          start.value <- in.tbl$scanstart.RTTime[1];      # value which needs to be subtracted from all events onsets to obtain the true onsets.
          if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
          inds <- which(in.tbl$TrialType == tt.ids[ttid]);  # TrialType ttid, all list lengths
          onsets <- (in.tbl$List1Slide.OnsetTime[inds] - start.value)/1000;  # /1000 to convert to seconds
          onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
          cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
        } else {
          cat("*\n", file=fout);     # add to the file with onsets for just this session
        }
      }
      close(fout); unlink(fout);     # close the file we just wrote for this session
    }
  }
  
  
  # block onset AND offset times; end the blocks at $Procedure == FixationGetReadyPROC, $getready.OnsetTime
  for (ssid in 1:length(session.ids)) {   # ssid <- 1;
    fout <- file(paste0(out.path, sub.id, "_Stern_", session.ids[ssid], "_blockONandOFF.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];
        inds <- which(in.tbl$Procedure == "FixationGetReadyPROC");   # same as above: block onsets
        if (length(inds) != 3) { stop(paste("not 3 FixationGetReadyPROC:", fname)); }
        onsets <- (in.tbl$getready.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
        offset.1 <- (in.tbl$Fixation.OnsetTime[inds[2]] - start.value)/1000;
        offset.2 <- (in.tbl$Fixation.OnsetTime[inds[3]] - start.value)/1000;
        offset.3 <- (in.tbl$FixationFinal.OnsetTime[which(in.tbl$Procedure == "FixationOnlyPROC")] - start.value)/1000; # last coded differently
        onsets <- sort(c(onsets, offset.1, offset.2, offset.3));  # sort so onsets and offsets nicely arranged
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else { cat("*\n", file=fout); }    # add to the file
    }
    close(fout); unlink(fout);
  }
  
  
  # make the block timing files: start the blocks at onset of first trial in block; duration until start of last trial in block.
  for (ssid in 1:length(session.ids)) {   # ssid <- 1;
    fout <- file(paste0(out.path, sub.id, "_Stern_", session.ids[ssid], "_block.txt"), 'wt'); 
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];         # value which needs to be subtracted from all events onsets for the true onsets.
        if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }          
        inds <- which(in.tbl$Procedure == "FixationGetReadyPROC");   # line before each block
        if (length(which(in.tbl$Procedure[inds+1] == "SternTrialPROC")) != 3) { stop(paste("not expected row ordering", fname)); }
        if (in.tbl$Procedure[inds[2]-1] != "SternTrialPROC" | in.tbl$Procedure[inds[3]-1] != "SternTrialPROC") { stop(paste("not expected row ordering", fname)); }
        
        # find the first and last trial of each block, by looking relative to the FixationGetReadyPROC inds (which mark start of each block)
        onsets <- (in.tbl$List1Slide.OnsetTime[inds+1] - start.value)/1000;  # inds+1 to get first TRIAL of each block
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        
        offset.1 <- (in.tbl$List1Slide.OnsetTime[inds[2]-1] - start.value)/1000;   # end of first block, in s
        offset.2 <- (in.tbl$List1Slide.OnsetTime[inds[3]-1] - start.value)/1000;
        offset.3 <- (in.tbl$List1Slide.OnsetTime[which(in.tbl$Procedure == "FixationOnlyPROC")-1] - start.value)/1000;  # last block, look for final fixation
        offset.1 <- offset.1 - (offset.1 %% 1.2);   # shift to closest previous TR.
        offset.2 <- offset.2 - (offset.2 %% 1.2); 
        offset.3 <- offset.3 - (offset.3 %% 1.2); 
        if (onsets[2]-offset.1 < 30 | onsets[3]-offset.2 < 30 | onsets[1] < 30) { stop(paste("breaks too short:", fname)); }
        # duration of each block is offset - onset
        cat(paste0(onsets[1], ":", (offset.1-onsets[1]), " ", onsets[2], ":", (offset.2-onsets[2]), " ", onsets[3], ":", (offset.3-onsets[3]), "\n"), file=fout);   
      } else { 
        cat("*\n", file=fout);     # * if run missing
      } 
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session and type
  }
  
  
  # finally, make the buttons output files. button is coded as 1 or 2 in ProbeSlide.RESP
  for (button in 1:2) {  # button <- 1;
    for (ssid in 1:length(session.ids)) {   # ssid <- 1;
      fout <- file(paste0(out.path, sub.id, "_Stern_", session.ids[ssid], "_button", button, ".txt"), 'wt');  # start an empty file for the onsets
      for (rid in 1:length(run.ids)) {    # rid <- 1;
        if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
          in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
          start.value <- in.tbl$scanstart.RTTime[1];   # value which needs to be subtracted from all events onsets for the true onsets.
          if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
          inds <- which(in.tbl$ProbeSlide.RESP == button);   # this isn't looking for NAs, accuracy, etc: just the actual button pushes
          onsets <- (in.tbl$ProbeSlide.RTTime[inds] - start.value)/1000;  # time button was pushed; /1000 to convert to seconds
          if (length(onsets) > 0) {
            onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
            cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
          } else {
            cat("*\n", file=fout);     # add to the file with onsets for just this session
            error.str <- c(error.str, paste("no button pushes:", fname));
          }
        } else {
          cat("*\n", file=fout);     # add to the file with onsets for just this session
        }
      }
      close(fout); unlink(fout);     # close the file we just wrote for this session and type
    }
  }
  
  return(list(err.str=error.str, eprimes=all.ins));
}



# ###########################    Stroop    ##########################
do.Stroop <- function(sub.id, which.DMCC, use.runs) {     
  # sub.id <- "130114"; which.DMCC <- 2; use.runs <- c("Bas1", NA, "Pro1", "Pro2", "Rea1", "Rea2");
  error.str <- "";   # empty string for returning error messages
  
  # build a list of the input eprime files, into the all.ins object so they only need to be read in once.
  # same as in "D:\gitFiles_ccplabwustl\R01\Jo\for800msecTR\knitr\singleSubSummary\singleSubSummary.rnw"
  all.ins <- list(Bas1=NA, Bas2=NA, Pro1=NA, Pro2=NA, Rea1=NA, Rea2=NA);
  for (ssid in 1:length(session.ids)) {
    for (rid in 1:2) {     # ssid <- 3; rid <- 1;
      if (length(which(use.runs == paste0(sess.ids[ssid], rid))) == 1) {   # run should be good (listed in use.runs)
        if (wustl.box == TRUE) {
          fname <- paste0('"', sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], "_run", rid, '.txt_raw"'); 
          tmp <- box_search(fname, type='file', file_extensions='csv', ancestor_folder_ids=folder.num); 
          if (length(tmp) == 1) { 
            in.tbl <- box_read_csv(tmp[[1]]$id);  
            in.tbl$Flicker.OnsetTime <- as.numeric(in.tbl$Flicker.OnsetTime);
            in.tbl$Fixation.OnsetTime <- as.numeric(in.tbl$Fixation.OnsetTime);
            in.tbl$FixationFinal.OnsetTime <- as.numeric(in.tbl$FixationFinal.OnsetTime);
            in.tbl$getready.OnsetTime <- as.numeric(in.tbl$getready.OnsetTime);
            in.tbl$Stimuli.OnsetTime <- as.numeric(in.tbl$Stimuli.OnsetTime);
            
            all.ins[[paste0(sess.ids[ssid], rid)]] <- in.tbl;
          } 
          if (length(tmp) == 0) { error.str <- c(error.str, paste("missing:", fname)); }
          if (length(tmp) > 1) { error.str <- c(error.str, paste("found > 1 file named", fname)); }
        } else {
          fname <- paste0(in.path, sub.id, "_", session.ids[ssid], "_Stroop", sess.ids[ssid], "_run", rid, ".txt_raw.csv"); 
          if (file.exists(fname)) { 
            in.tbl <- read.csv(fname); 
            all.ins[[paste0(sess.ids[ssid], rid)]] <- in.tbl; 
          } else { error.str <- c(error.str, paste("missing:", fname)); }
        }
      }
    }
  }
  
  # make the events files for all trials
  for (ssid in 1:length(session.ids)) {   # ssid <- 2;
    fout <- file(paste0(out.path, sub.id, "_Stroop_", session.ids[ssid], "_allTrials.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];    # value which needs to be subtracted from all events onsets for the true onsets.
        if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
        inds <- which(!is.na(in.tbl$TrialType));
        onsets <- (in.tbl$Stimuli.OnsetTime[inds] - start.value)/1000;  # /1000 to convert to seconds
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else {
        cat("*\n", file=fout);     # add to the file with onsets for just this session
      }
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session and trial type
  }
  
  
  # make the events files for the Con and InCon TrialType trials, separately by LWPC: PC50 all sessions. bias = MC for bas; bias = MI for pro&rea; buff = MC for rea, cong.
  for (lbl in c("PC50", "bias", "buff")) {   # lbl <- "PC50";
    for (ttype in c("InCon", "Con")) {   # need one onset file for each $TrialType (Con and InCon)   # ttype <- "Con";
      for (ssid in 1:length(session.ids)) {   # ssid <- 2;
        if (session.ids[ssid] == "reactive") { need.length <- 120; } else { need.length <- 108; }   # ready for error-checking ... fixed number of trials.
        make.file <- TRUE;  # start off this loop
        if (session.ids[ssid] == "baseline" & lbl == "buff") { make.file <- FALSE; }
        if (session.ids[ssid] == "proactive" & lbl == "buff") { make.file <- FALSE; }
        if (session.ids[ssid] == "reactive" & lbl == "buff" & ttype == "InCon") { make.file <- FALSE; }
        if (make.file == TRUE) {  # this session has events of this type, so read in the (converted) eprime output and make an onset file
          fout <- file(paste0(out.path, sub.id, "_Stroop_", session.ids[ssid], "_", lbl, ttype, ".txt"), 'wt');  # start an empty file for the onsets
          for (rid in 1:length(run.ids)) {    # rid <- 1;
            if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
              in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
              if (length(which(in.tbl$Procedure == "StroopTrialPROC")) != need.length) { stop(paste("not right number of trials:", fname)); }  # here's the trial error-checking
              start.value <- in.tbl$scanstart.RTTime[1];    # value which needs to be subtracted from all events onsets for the true onsets.
              if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }
              if (lbl == "PC50") { inds <- which(in.tbl$TrialType == ttype & in.tbl$LWPC == "PC50"); }
              if (lbl == "bias" & session.ids[ssid] == "baseline") { inds <- which(in.tbl$TrialType == ttype & in.tbl$LWPC == "MC"); }
              if (lbl == "bias" & session.ids[ssid] != "baseline") { inds <- which(in.tbl$TrialType == ttype & in.tbl$LWPC == "MI"); }
              if (lbl == "buff" & session.ids[ssid] == "reactive") { inds <- which(in.tbl$TrialType == ttype & in.tbl$LWPC == "MC"); }
              if (length(inds) < 1) { stop(paste("no trials?", fname)); }
              onsets <- (in.tbl$Stimuli.OnsetTime[inds] - start.value)/1000;
              onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
              cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
              rm(inds);  # so can't accidently use them in the next loop.
            } else {
              cat("*\n", file=fout);     # add to the file with onsets for just this session
            }
          }
          close(fout); unlink(fout);     # close the file we just wrote for this session and trial type
        }
      }
    }
  }
  
  
  # block onset AND offset times; end the blocks at $Procedure == FixationGetReadyPROC, $getready.OnsetTime
  for (ssid in 1:length(session.ids)) {   # ssid <- 2;
    fout <- file(paste0(out.path, sub.id, "_Stroop_", session.ids[ssid], "_blockONandOFF.txt"), 'wt');  # start an empty file for the onsets
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];
        inds <- which(in.tbl$Procedure == "FixationGetReadyPROC");   # same as above: block onsets
        if (length(inds) != 3) { stop(paste("not 3 FixationGetReadyPROC:", fname)); }
        onsets <- (in.tbl$getready.OnsetTime[inds] - start.value)/1000;  # Nick says use OnsetTime, not StartTime; /1000 to convert to seconds
        offset.1 <- (in.tbl$Fixation.OnsetTime[inds[2]] - start.value)/1000;
        offset.2 <- (in.tbl$Fixation.OnsetTime[inds[3]] - start.value)/1000;
        offset.3 <- (in.tbl$FixationFinal.OnsetTime[which(in.tbl$Procedure == "FixationOnlyPROC")] - start.value)/1000; # last coded differently
        onsets <- sort(c(onsets, offset.1, offset.2, offset.3));  # sort so onsets and offsets nicely arranged
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        cat(paste0(paste(onsets, collapse=" "), " \n"), file=fout);     # add to the file with onsets for just this session
      } else { cat("*\n", file=fout); }    # add to the file
    }
    close(fout); unlink(fout);
  }
  
  
  # make the block timing files: start the blocks at onset of first trial in block; duration until start of last trial in block.
  for (ssid in 1:length(session.ids)) {   # ssid <- 1;
    fout <- file(paste0(out.path, sub.id, "_Stroop_", session.ids[ssid], "_block.txt"), 'wt'); 
    for (rid in 1:length(run.ids)) {    # rid <- 1;
      if (length(all.ins[[paste0(sess.ids[ssid], rid)]]) > 1) {   
        in.tbl <- all.ins[[paste0(sess.ids[ssid], rid)]];   # just to simplify the code
        start.value <- in.tbl$scanstart.RTTime[1];         # value which needs to be subtracted from all events onsets for the true onsets.
        if (is.na(start.value) | start.value < 1000) { stop("invalid start.value"); }          
        inds <- which(in.tbl$Procedure == "FixationGetReadyPROC");   # line before each block
        if (length(which(in.tbl$Procedure[inds+1] == "StroopTrialPROC")) != 3) { stop(paste("not expected row ordering", fname)); }
        if (in.tbl$Procedure[inds[2]-1] != "StroopTrialPROC" | in.tbl$Procedure[inds[3]-1] != "StroopTrialPROC") { stop(paste("not expected row ordering", fname)); }
        
        # find the first and last trial of each block, by looking relative to the FixationGetReadyPROC inds (which mark start of each block)
        onsets <- (in.tbl$Stimuli.OnsetTime[inds+1] - start.value)/1000;  # inds+1 to get first TRIAL of each block
        onsets <- onsets - (onsets %% 1.2);   # shift to closest previous TR.
        
        offset.1 <- (in.tbl$Stimuli.OnsetTime[inds[2]-1] - start.value)/1000;   # end of first block, in s
        offset.2 <- (in.tbl$Stimuli.OnsetTime[inds[3]-1] - start.value)/1000;
        offset.3 <- (in.tbl$Stimuli.OnsetTime[which(in.tbl$Procedure == "FixationOnlyPROC")-1] - start.value)/1000;  # last block, look for final fixation
        offset.1 <- offset.1 - (offset.1 %% 1.2);   # shift to closest previous TR.
        offset.2 <- offset.2 - (offset.2 %% 1.2); 
        offset.3 <- offset.3 - (offset.3 %% 1.2); 
        if (onsets[2]-offset.1 < 30 | onsets[3]-offset.2 < 30 | onsets[1] < 30) { stop(paste("breaks too short:", fname)); }
        # duration of each block is offset - onset
        cat(paste0(onsets[1], ":", (offset.1-onsets[1]), " ", onsets[2], ":", (offset.2-onsets[2]), " ", onsets[3], ":", (offset.3-onsets[3]), "\n"), file=fout);   
      } else { 
        cat("*\n", file=fout);     # * if run missing
      } 
    }
    close(fout); unlink(fout);     # close the file we just wrote for this session and type
  }
  
  return(list(err.str=error.str, eprimes=all.ins));
}
