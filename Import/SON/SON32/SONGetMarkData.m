% SONGETMARKDATA returns the timings and marker values for a Marker, AdcMark,
% RealMark or TextMark channel
% 
% Implemented through SONGetMarkData.dll
% 
% [npoints, times, markers]=
%             SONGETMARKDATA(fh, chan, maxpoints, stime, etime{, filtermask})
%             
%            INPUTS: FH = file handle
%                    CHAN = channel number 0 to SONMAXCHANS-1
%                    MAXPOINTS = Maximum number of data values to return
%                                (up to 32767, if zero will be set to
%                                   32767)
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
%                    DATA = an NPOINT x 4 byte array, with 4 markers
%                           for each of the timestamps in TIMES.
% 
% Note: For easier compatability with version 1.0 of the library use a
% structure for the outputs e.g.
% [npoints, data.timings, data.markers]=
%                         SONGETMARKDATA(fh, chan, maxpoints, stime, etime)
%
% For error codes, see the CED documentation
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London