function flag=SONSave(fh, chan, sTime, bKeep)
% SONSAVE sets the write state for a channel from a specified time
% 
% FLAG=SONSAVE(FH, CHAN, STIME, BKEEP)
% INPUTS: FH is the SON file handle
%         CHAN is a channel number (0-SONMaxChans()-1) or -1 for all
%         channels  
%         STIME the time for this write state to take effect from (clock
%         ticks)
%         BKEEP non-zero to keep, zero to discard data
%         
% Returns 0 if changes are effective, 0 if not or a negative error code
%     
% See CED documentation for further details
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
        
flag=calllib('son32','SONSave', fh, chan, sTime, bKeep);