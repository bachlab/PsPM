function state=SONIsSaving(fh, chan)
% SONISSAVING returns the save state for a specified channel
% 
% STATE=SONISSAVING(FH, CHAN)
% where FH is the SON file handle and CHAN is the channel number 
% (0 - SONMaxChan()-1)
% Returns 0 if not saving, 1 if saving or a negative error code
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

state=calllib('son32','SONIsSaving', fh, chan);
