%Rt extraction Code
%Last Updated: Jan/16/19
%Purpose: this code is built to extract the reaction time of the participant
%Within the DMCC data set
%A switch has been added to allow for better extraction with the FORM3 Microphone
%using this switch will create use a secondary script to clean audio before
%passing it through the extraction process. 
%It will also copy the results from the first channel to the second channel if the second doesn't produce any data 

%USAGE: set the base directory. this should point to the containing folder for the subject_session directories 
%set to true or false if you are using the FOMRI3 microphone
%set the subjects you want to extract from
%set the sessions you want to extract from
%Run

clear
close all

%Users edit below

bas_dir='/scratch1/MitchJeffers/StroopRT/BadRTs(DMCC2)' %Where the files live
FOMRI3Mic = true; %Set to 'true' if you are using the the FOMRI3 mic. 'false' if its not true 

subjects={'DMCC6960387'}%subjects you want to process
sessions={'reactive'}%sessions you want to process for each subject
addpath('./audioAnalysisLibraryCode/library') %point this towards you directory where this library live. 
addpath('./rt_v1.4')

%End users edit above

for j=1:length(subjects)
    for i=1:length(sessions)
        switch sessions{i}%get the type to name the nested directory
            case 'baseline'
                Type='LWMC'
            case 'proactive'
                Type='LWMI'
            case 'reactive'
                Type='ISPC'
        end 
        
        in_dir=fullfile(bas_dir, subjects{j}, [subjects{j} '_' sessions{i}], 'Stroop', 'audiofiles') %where the current files live
        out_dir=fullfile(bas_dir, subjects{j},[subjects{j} '_' sessions{i}],'Stroop','RTextractions', Type) % where the results belong
        if 7==exist(out_dir,'dir')
            rmdir(out_dir, 's')
        end
        if 7==exist(in_dir,'dir') %Check if the in dir exist
            if (FOMRI3Mic) %if its the FOMRI3Mic do some cleaning
                system(['bash Normalize.sh ' strrep(strrep(in_dir,'(','\('),')','\)')]) %Run the sox cleaning script. supply the indirectory as an argument but make sure the parethesis are escaped
                in_dir = fullfile(in_dir, 'Clean') %The new in_dir is nested in the audiofiles folder under the name Clean
            end
            
            c_seriesRT(in_dir, out_dir, 0.1, Type) %
            [files_energy1, estimate1_from_energy1, estimate2_from_energy1] = c_silence_detector(out_dir, '*energy1.wav', '_silencedet1')
            [files_energy2, estimate1_from_energy2, estimate2_from_energy2] = c_silence_detector(out_dir, '*energy2.wav', '_silencedet2')
        
            if FOMRI3Mic && ( size(files_energy2,1) < size(files_energy1,1)/2 )
                files_energy2=files_energy1
                estimate1_from_energy2=estimate1_from_energy1
                estimate2_from_energy2=estimate2_from_energy1
            end
            
            save(fullfile(out_dir, ['RTs_silence_detector_' Type '.mat']), 'estimate*', 'files*') 
            c_writetablesRTs(out_dir, fullfile(out_dir, ['RTs_' Type '.mat']), fullfile(out_dir, ['RTs_silence_detector_' Type '.mat']))
        else 
            disp([in_dir ' doesnt exist please check'])
            exit
        end
    end
end