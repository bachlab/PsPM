% SONSETMARKER replaces the data associated with a marker on disc
% 
% Implemented through SONSetMarker.dll
% 
% RET=SONSETMARKER(FH, CHAN, TIME, NEWTIME, {NEWMARKERS, {NEWEXTRA}})
%   FH = the SON file handle
%   CHAN = the target marker channel
%   TIME = the current timestamp of the target marker entry (clock ticks)
%   NEWTIME = a new time that will replace the timestamp in TIME
%   NEWMARKERS = if present, a set of 4 uint8 marker values that will replace
%               those on disc
%   NEWEXTRA = if present, the extra data to replace all or some of the 
%               existing extra data
%                These may be:  int16 (for AdcMark)
%                               single (for RealMark)
%                               or uint8 (for TextMark)
%                               (N.B. not char which is 16bit in matlab)
%
% The data type for NEWEXTRA must match that of the target channel (the function
% returns SON_NO_EXTRA if it does not. 
%
% e.g SONSetMarker(fh, 2, 140100, 140200)
%     replaces the timestamp only
%     SONSetMarker (fh, 2, 140100, 14020, uint8([22 33 44 55]))
%     replaces the markers also
%     SONSetMarker (fh, 2, 140100, 14020, uint8([22 33 44 55]), int16([0 0]))
%     also replaces the first two extra data entries with zero on an AdcMark channel
%     
% Returns: 1 if the replacement occured.    
%          0 if not e.g. NEWEXTRA is longer than the existing entry or the 
%              new timestamp would break the temporal sequence of successive
%              entries
%          or an negative error code
%          
%     
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
