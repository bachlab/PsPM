% SONGETEVENTDATA returns the timings for an Event or marker channel
% 
% Implemented through SONGetEventData.dll
% 
% [npoints, times, levlow]=
%             SONGETEVENTDATA(fh, chan, maxpoints, stime, etime{, filtermask})
%             
%            INPUTS: FH = file handle
%                    CHAN = channel number 0 to SONMAXCHANS-1
%                    MAXPOINTS = Maximum number of data values to return
%                    STIME  = the start time for the data search
%                                   (in clock ticks)
%                    ETIME = the end time for teh search
%                                    (in clock ticks)
%                    FILTERMASK  if present is  a filter mask structure
%                                   There will be no filtering if this is
%                                   absent.
%           OUTPUTS: NPOINTS= number of data points returned
%                               or a negative error
%                    TIMES = an NPOINT column vector containing the
%                               timestamps (in clock ticks)
%                    LEVLOW = For a EventBoth (level) channel, 
%                               this is set to 1 if the first event
%                               is a high to low transition, 0 otherwise
% 
%
% For error codes, see the CED documentation
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
