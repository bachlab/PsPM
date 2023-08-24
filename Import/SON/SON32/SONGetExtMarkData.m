% SONGETEXTMARKDATA returns the timings, marker values and extra data
% for an AdcMark, RealMark or TextMark channel
%
% Implemented through SONGetExtMarkData.dll
%
% [npoints, times, markers, extra]=
%        SONGETEXTMARKDATA(fh, chan, maxpoints, stime, etime{, filtermask})
%
%            INPUTS: FH = file handle
%                    CHAN = channel number 0 to SONMAXCHANS-1
%                    MAXPOINTS = Maximum number of data values to return
%                                (up to 32767, if zero this will be set to
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
%                    MARKERS = an NPOINT x 4 byte array, with 4 markers
%                           for each of the timestamps in TIMES.
%                    EXTRA= An X x NPOINT array. The NPOINT columns contain
%                            the extra data for each marker. The length of 
%                            the columns varies between channels.
%                            EXTRA is int16 for ADCMark channels, single 
%                               for RealMark and uint8 for TextMark
%
% Note: If required, cast TextMark EXTRA data to type char in MATLAB 
%       If you do not need the EXTRA data, use SONGetMarkData instead
%
% For error codes, see the CED documentation
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
