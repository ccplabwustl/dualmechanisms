function RTms = c_calculateRT(filename, bias, RC)

% filename: name of wav file
% bias: audio capture bias, in seconds
% RC: envelope parameter
show_plot           = 0;    % flag to show RT plots (1) or not (0)
energy_threshold    = 0.3;  % move this parameter to set energy level for response onset
filename
close all
[x, fs] = audioread(filename);

% remove onset
K0  = (bias) * fs;    % Trial onset = audio_signal - bias
x   = x(K0:end,:);  % onset bias removed 
x_aux1  = x(:,1);

% time vector
%t   = (0:size(x,1)-1)/fs;

% a tolerance where human response is not possible (300 ms?)
% Ks      = 0.3 * fs;     % assuming no human response can be faster than 300 ms
%x_aux1  = x1(Ks:end);

%% spectral subtraction (on x)

ss_x1   = rt_SSBoll79(x_aux1, fs);  % first
ss_xx1  = rt_SSBoll79(ss_x1,fs);    % second
ss_xxx1 = rt_SSBoll79(ss_xx1,fs);   % third


%% energy, zero cross (on x)

[e_x1, z_x1, ~ , fs]        = rt_energy_zc(ss_x1,fs);
% ge_x                      = abs(gradient(e_x));
[e_xx1, z_xx1, ~ , fs]      = rt_energy_zc(ss_xx1,fs);
%  ge_xx                    = abs(gradient(e_xx));
[e_xxx1, z_xxx1, ~ , fs]    = rt_energy_zc(ss_xxx1,fs);
% ge_xxx                    = abs(gradient(e_xxx));


%% envelopes
t   = (0:size(e_x1,1)-1)/fs;

env_ex1      = rt_envelope(e_x1, t, RC);
env_exx1     = rt_envelope(e_xx1, t, RC);
env_exxx1    = rt_envelope(e_xxx1, t, RC);

%% RTs

% rt_aux_k  = find(env_exxx > (0.8* max(abs(env_exxx))));    
% a tolerance where human response is not possible (300 ms?)
Ks          = 0.3 * fs;     % assuming no human response can be faster than 300 ms
e_aux1    = e_xxx1(Ks:end);
rt_aux_k1   = find(e_aux1 > energy_threshold);    %  
if isempty(rt_aux_k1)                       
    RT_ms1 = NaN;                       % did not find a word
else
    rt_aux_k1   = rt_aux_k1(1);         % temporary hack
    rt_ms1      = t(rt_aux_k1);
    RT_ms1      = rt_ms1 + 0.3;
end

e_xxx1(rt_aux_k1 + (0.3 * fs)) = 1;
audiowrite([strrep(filename, '.wav', '' ) '_energy1.wav'], e_xxx1, fs)
%% If stereo signal
if (size(x,2) == 2)

    x_aux2      = x(:,2);

    ss_x2   = rt_SSBoll79(x_aux2, fs);  % first
    ss_xx2  = rt_SSBoll79(ss_x2,fs);    % second
    ss_xxx2 = rt_SSBoll79(ss_xx2,fs);   % third
    
    [e_x2, z_x2, ~ , fs]        = rt_energy_zc(ss_x2,fs);
    % ge_x                      = abs(gradient(e_x));    
    [e_xx2, z_xx2, ~ , fs]      = rt_energy_zc(ss_xx2,fs);
    %  ge_xx                    = abs(gradient(e_xx));    
    [e_xxx2, z_xxx2, ~ , fs]    = rt_energy_zc(ss_xxx2,fs);
    % ge_xxx                    = abs(gradient(e_xxx));
    
    env_ex2      = rt_envelope(e_x2, t, RC);
    env_exx2     = rt_envelope(e_xx2, t, RC);
    env_exxx2    = rt_envelope(e_xxx2, t, RC);
    
    % rt_aux_k  = find(env_exxx > (0.8* max(abs(env_exxx))));
    e_aux2    = e_xxx2(Ks:end);
    rt_aux_k2   = find(e_aux2 > energy_threshold); 

    if isempty(rt_aux_k2)
        RT_ms2 = NaN;
        RT_ms2 = RT_ms1;
    else
        rt_aux_k2  = rt_aux_k2(1);          % temporary hack
        rt_ms2 = t(rt_aux_k2);
        RT_ms2 = rt_ms2 + 0.3;
        
        e_xxx2(rt_aux_k2 + (0.3 * fs)) = 1;
        audiowrite([strrep(filename, '.wav', '' ) '_energy2.wav'], e_xxx2, fs)
 
    end

    
    RTms = [RT_ms1 RT_ms2];    
else
    RT_ms2 = RT_ms1;
    RTms = [RT_ms1 RT_ms2];
end


%% some plots

% % figure
% % subplot(4,1,1);plot(e_x)
% % title('energy')
% % subplot(4,1,2);plot(e_x)
% % subplot(4,1,3);plot(e_xx)
% % subplot(4,1,4);plot(e_xxx)

if show_plot
    figure
    plot(t,e_xxx1)
    hold on
    plot(t, env_exxx1, '--r')
    if ~isnan(RT_ms1)
        stem(RT_ms1,0.5, 'og')
        hold on
    end
    
    
    if exist('x_aux2', 'var')
        figure
        plot(t,e_xxx2)
        hold on
        plot(t, env_exxx2, '--r')
        if ~isnan(RT_ms2)
            stem(RT_ms2,0.5, 'og')
            hold on
        end
        pause
    end
    title(filename)
end

end


 




