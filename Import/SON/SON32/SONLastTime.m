% SONLASTTIME returns information about the last entry on a channel
% before a specified time
%
% Implemented through SONLastTime.dll
%
%[time, data, markers, markerflag]=...
%                       SONGETADCDATA(fh, chan, eTime, sTime{, FilterMask})
%
%   INPUTS: FH SON File Handle
%           CHAN Channel number (1 to SONMaxChannels)
%           STIME Searches back from this time
%           ETIME stops search at this time (eTime must be less than sTime)
%           FILTERMASK, if present, a filter mask
%
%   OUTPUTS: TIME The time of the last data point between ETIME and STIME
%                   or a negative error code
%            DATA Value at TIME for an ADC or Real channel.
%                   For an EventBoth channel the InitLow value
%            MARKERS the marker codes for the event at TIME for
%                   a marker channel
%            MARKERFLAG Set to 1 if CHAN is a marker channel, 0 otherwise
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London