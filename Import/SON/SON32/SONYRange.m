function minmax=SONYRange(fh, chan)
% SONYRANGE returns the expected minimum and maximum values for a channel
% 
% MINMAX=SONYRANGE(FH, CHAN)
% 
% MINMAX is a 2-element vector containing the minimum and maximum values
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

minmax(1)=realmin;
minmax(2)=realmax;
[minmax(1),minmax(2)]=calllib('son32','SONYRange', fh, chan, minmax(1), minmax(2));