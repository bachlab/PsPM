function SONSetADCScale(fh, chan, scale)
% SONSETADCSCALE sets the scale on an ADC channel
% 
% SONADCOFFSET(FH, CHAN, SCALE)
% where FH is the SON file handle, CHAN is the channel number and SCALE is
% the new value to be written to the file
%
% An ADC value is converted to a real value as:
%         Real value=(16-bit ADC value * scale / 6553.6) + offset
%
% see also: SONSetADCOffset
%
% No return value
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

calllib('son32','SONSetADCOffset', fh, chan, scale);
