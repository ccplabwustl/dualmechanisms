% Computation of ST-ZCR and STE of a speech signal.
%
% Functions required: zerocross, sgn, winconv.
%
% Author: Nabin Sharma
% Date: 2009/03/15
% Modified 10/2014 (carolina, ccp)
% Note: returns absolute values! (E is always positive, but we return the
% inverse of the zero crossing rate)
function [e, zcross, x, Fs] = rt_energy_zc(x,Fs)


x = x.';
x   = x(1,:);

N   = length(x); % signal length
n   = 0:N-1;
ts  = n*(1/Fs); % time for signal

% define the window
wintype = 'rectwin';
winlen  = 661; % make the window about 30 [ms]
winamp  = [0.5,1]*(1/winlen);

% find the zero-crossing rate
zc  = zerocross(x,wintype,winamp(1),winlen);
% find the energy
E   = energy(x,wintype,winamp(2),winlen);

% time index for the ST-ZCR and STE after delay compensation
out = (winlen-1)/2:(N+winlen-1)-(winlen-1)/2;

% % % % to plot:
% % % t   = (out-(winlen-1)/2)*(1/Fs);
% % % figure;
% % % plot(ts,x); hold on;
% % % plot(t,zc(out),'r','Linewidth',2); xlabel('t, seconds');
% % % title('Short-time Zero Crossing Rate');
% % % legend('signal','STZCR');
% % % 
% % % figure;
% % % plot(ts,x); hold on;
% % % plot(t,E(out),'r','Linewidth',2); xlabel('t, seconds');
% % % title('Short-time Energy');
% % % legend('signal','STE');


e = E(out(1:end-1));
z = zc(out(1:end-1));

e = e/max(max(abs(E)));
z = z/max(max(abs(z)));

% % % % to plot:
% % % t = (0:length(x)-1)/Fs;
% % % figure
% % % title( 'Short Time Energy and Zero Crossing Rate')
% % % plot(t, x)
% % % hold on
% % % plot(t, e, 'r--')
% % % plot(t, -z+1, 'g--')
% % % xlabel('time [s]')
% % % legend
zcross = -z+1; %inverse of z
x = x';
e = e';
zcross = zcross';
end