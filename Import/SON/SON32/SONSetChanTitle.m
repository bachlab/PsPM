function SONSetChanTitle(fh, chan, str)
% SONSETCHANTITLE sets the channel title
% FH = SON file handle
% CHAN = channel number (0 to Max-1)
% str = string with new title
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

global SON_TITLESZ;
str=str(1:min(SON_TITLESZ,length(str)));
calllib('son32','SONSetChanTitle', fh, chan, str);