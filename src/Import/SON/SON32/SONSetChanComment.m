function SONSetChanComment(fh, chan, str)
% SONSETCHANCOMMENT sets the channel comment
% FH = SON file handle
% CHAN = channel number (0 to Max-1)
% str = string with new comment
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

global SON_CHANCOMSZ;
str=str(1:min(SON_CHANCOMSZ,length(str)));
calllib('son32','SONSetChanComment', fh, chan, str);
