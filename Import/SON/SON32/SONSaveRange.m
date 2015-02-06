function flag=SONSaveRange(fh, chan, startTime, endTime)
% SONSAVERANGE sets the write state to save for a channel in the given time range
% 
% FLAG=SONSAVERANGE(FH, CHAN, STARTTIME, ENDTIME)
% INPUTS: FH is the SON file handle
%         CHAN is a channel number (0-SONMaxChans()-1) or -1 for all
%              channels 
%         STARTTIME the time to save data from
%         ENDTIME the end time
%       Note that times are in clock ticks
%
% Returns 0 if changes are effective, 0 if not or a negative error code
%     
% See CED documentation for further details
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
        
flag=calllib('son32','SONSaveRange', fh, chan, startTime, endTime);