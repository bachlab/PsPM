function MaxTime=SONChanMaxTime(fh, chan)
% SONCHANMAXTIME returns the sample time for the last data item on a channel
% 
% MAXTIME=SONCHANMAXTIME(FH, CHAN) 
% where  FH is the SON file handle
%        CHAN the channel (0-SONMaxChannels()-1)
%
%        MAXTIME is returned in clock ticks
% 
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

MaxTime=calllib('son32','SONChanMaxTime',fh,chan);
return;
