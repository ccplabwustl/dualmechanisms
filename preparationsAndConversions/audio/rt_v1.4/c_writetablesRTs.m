
function c_writetablesRTs(destination, rts_energy, rts_silencedet)

load(rts_energy)
load(rts_silencedet)

%This is very hardcoded to the eprime file names :P
%% everyone to cell

% first load the MAT files

% for energy only estimates
RT = round(RT,3);
energy_cell     = struct2cell(list)';
if size(RT,2) == 2
    energy_cell     = cat(2, energy_cell(:,1), num2cell(RT(:,1)) , num2cell(RT(:,2))); %#ok<*NODEF>
else
    energy_cell     = cat(2, energy_cell(:,1), num2cell(RT(:,1)))
end

% for energy + silence_detector estimates
tmp1 = num2cell(estimate1_from_energy1);
tmp2 = num2cell(estimate2_from_energy1);
silencedet_cell_energy1 = cat(2,files_energy1, tmp1, tmp2);
try
tmp1 = num2cell(estimate1_from_energy2);
tmp2 = num2cell(estimate2_from_energy2);
silencedet_cell_energy2 = cat(2,files_energy2, tmp1, tmp2);
catch
end
clear tmp1 tmp2

% Now, cells to tables, sorted by filename
if size(RT,2) == 2
    if ~isempty(energy_cell)
        tmp    = cell2table(energy_cell, 'VariableNames', {'filename','RTestimate_energy1','RTestimate_energy2'});
    end
else 
    if ~isempty(energy_cell)
        tmp    = cell2table(energy_cell, 'VariableNames', {'filename','RTestimate_energy1'});
    end
end

if ~isempty(silencedet_cell_energy1)
    tmp1    = cell2table(silencedet_cell_energy1, 'VariableNames',{'filename','firstRTestimate_energy1','secondRTestimate_energy1'});
end
try
if ~isempty(silencedet_cell_energy2)
    tmp2    = cell2table(silencedet_cell_energy2, 'VariableNames',{'filename','firstRTestimate_energy2','secondRTestimate_energy2'});
end
catch
end

clear silencedet* energy_cell RT
%% sort table rows by filename

%energy

if exist('tmp', 'var')
        writetable(tmp, fullfile(destination,'RTs_energy.txt'),'FileType', 'text', 'Delimiter', '\t')
end

% silence detector

if exist('tmp1', 'var')
    writetable(tmp1, fullfile(destination,'RTs_silencedet_energy1.txt'),'FileType', 'text', 'Delimiter', '\t')
end

try
if exist('tmp2', 'var')
    writetable(tmp2, fullfile(destination,'RTs_silencedet_energy2.txt'),'FileType', 'text', 'Delimiter', '\t')
end
catch
end


end


