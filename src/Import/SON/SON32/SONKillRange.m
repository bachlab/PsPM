function flag=SONKillRange(fh, chan, startTime, endTime)
% SONKILLRANGE attempts to discard data from a file between two times
% 
% FLAG=SONKILLRANGE(FH, CHAN, STARTTIME, ENDTIME)
% FH is the SON file handle, CHAN  is the channel number and STARTTIME and
% ENDTIME specify the time range (in clock ticks within which to discard
% data. 
%
% This is only useful when data are being written to a new file. 
% See CED documentation for details
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

flag=calllib('son32','SONKillRange', fh, chan, startTime, endTime);