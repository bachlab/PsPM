function bytes=SONItemSize(fh, chan)
% SONITEMSIZE returns the size of a data item on the specified channel (bytes)
% 
% BYTES=SONITEMSIZE(FH, CHAN)
% where FH is the SON file handle and CHAN is the channel number 
% (0 - SONMaxChan()-1)
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

bytes=calllib('son32','SONItemSize', fh, chan);