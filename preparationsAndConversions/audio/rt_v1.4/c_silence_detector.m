function [list, S1, S2] = c_silence_detector(origin, filestring, suffix)
% origin        : origin folder
% filestring    : wildcard to select files,
% Processes a directory containing WAV files (uses wav file of energy signals!)

try
    list = dir(fullfile(origin, filestring));
catch
    
end


if isempty(list)
    sprintf('No files to process.\n')
	S1 = '';
	S2 = '';
	return
else
	tmp = cell(length(list),1);
    S1 = zeros(length(list),1);
	S2 = zeros(length(list),1);
	for i = 1:length(list)
        
        close all
        i
               
        filename = fullfile(origin,list(i).name);
        tmp{i} = filename;
        [x,fs] = audioread(filename);
        [s1,e1,s2,e2,logE, Z] = silenceDetectorUtterance(filename, 0.050, 0.001);
        
        if isnan(s2)
        	s2 = s1;
        	e2 = e1;
        end
        
        
        S1(i) = s1;
        S2(i) = s2;
 
        % write audio file if no one is NaN
        if ~isnan(s1) && ~isnan(s2)
            
            k1 = round(s1 * fs);
            % % %            figure
            % % %            plot(x)
            % % %            hold on
            % % %            stem(k1, 1, 'r')
            x(k1) = 0.6;
        
            k2 = round(s2 * fs);
            % % %            figure
            % % %            plot(x)
            % % %            hold on
            % % %            stem(k1, 1, 'r')
            % % %            stem(k2, 1, 'g')
            x(k2) = 0.8;
            
            audiowrite([strrep(filename, '.wav', '' ) suffix '.wav'], x, fs)
        end
        
end

    list = tmp;
end

end