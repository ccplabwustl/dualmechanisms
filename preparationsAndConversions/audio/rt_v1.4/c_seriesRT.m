function c_seriesRT(origin, destination, bias, condition)
% origin        : origin folder
% destination   : destination folder
% bias          : audio capture bias
% condition     : condition name 
% Processes a directory containing WAV files

% TO DO: add arguments parsing

copyFilesByType(origin, destination, 'wav')

list = dir(fullfile(destination, '*.wav'));
for i = 1:length(list)
    filename    = list(i).name;
    filename
    newname     = [zeropad(filename,4) '.wav'];
    movefile(fullfile(destination,filename), fullfile(destination,newname))
end
    
    
list = dir(fullfile(destination, '*.wav'));    
RT = cell(length(list),1);
for i = 1:length(list)
    i
    filename = list(i).name;
    
    RT{i} = c_calculateRT(fullfile(destination,filename), bias, 0.5);
    list(i).RT = RT{i};
    
end

RT = cell2mat(RT);
save(fullfile(destination, ['RTs_' condition '.mat']), 'list', 'RT')





