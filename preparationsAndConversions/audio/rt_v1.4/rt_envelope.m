function y = rt_envelope(x,t,RC)
% Compute the output of an envelope detection circuit to the input x,
% defined at points t, with resistor-capacitor product RC
%
% Circuit looks like (please view in fixed-width font!):
%
%        |------>|-----|---------------o
%        |     Diode   |      |
%   +    |            _!_     >        +
%  x(t) ( )           --- C   < R     y(t)
%   -    |             |      >        -
%        |             |      |
%        |-------------|---------------o
%


% % % if length(x)~=length(t)
% % %   disp('ERROR: lengths of x and t must agree');
% % %   y=[];
% % %   return;
% % % end;
% % % 
% % % if find((t(2:end)-t(1:end-1)) <= 0)
% % %   disp('ERROR: t must be strictly increasing');
% % %   y=[];
% % %   return;
% % % end;
% % % 
% % % if RC<=0
% % %   disp('ERROR: time constant must be positive');
% % %   y=[];
% % %   return;
% % % end;

alpha=1/RC;
vc      = zeros(length(t),1);
y       = zeros(length(t),1);
y(1)    = max(0,x(1));
vc(1)   = y(1);

for i = 2:length(t)
  vc(i) =vc(i-1)*exp(-alpha*(t(i)-t(i-1)));
  y(i)  =max(vc(i),x(i));
  vc(i) =y(i);
end



end