function ret=SONSetBuffering(fh, chan, bytes)
%SONSETBUFFERING specifies the buffer size for writing to a channel
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

ret=calllib('son32','SONSetBuffering', fh, chan, bytes);