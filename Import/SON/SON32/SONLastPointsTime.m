% SONLASTPOINTSTIME returns the time for which a read will terminate
%
% Implemented through SONLastPointsTime.dll
%
% TIME=SONGETADCDATA(FH, CHAN, ETIME, STIME, LPOINTS, BADC {, FILTERMASK})
%
%   INPUTS: FH SON File Handle
%           CHAN Channel number (1 to SONMaxChannels)
%           STIME Searches back from this time
%           ETIME stops search at this time (eTime must be less than sTime)
%           LPOINTS the number of points it is dsired to read
%           BADC ADCMark data will be treated as Adc if this set
%           FILTERMASK, if present, a filter mask
%
% Returns the time at which the read will end i.e. the time of the final data
% point or a negative error code
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London