% SONGETREALDATA returns data for Adc, AdcMark, RealWave ( and RealMark?)
% data channels
%
% Implemented through SONGetRealData.dll
%
% [npoints, bTime, data]=SONGETREALDATA(fh, chan,...
%               maxpoints, sTime, eTime{, FilterMask})
%
%            INPUTS: FH = file handle
%                    CHAN = channel number 0 to SONMAXCHANS-1
%                    MAXPOINTS = Maximum number of data points to return
%                                   The routine will calculate MAXPOINTS
%                                   if this is passed as zero or less.
%                    STIME  = the start time for the data search
%                                   (in clock ticks)
%                    ETIME = the end time for teh search
%                                    (in clock ticks)
%                    FILTERMASK  if present is  a filter mask structure
%                                   There will be no filtering if this is
%                                   absent.
%           OUTPUTS: NPOINTS= number of data points returned
%                               or a negative error
%                    BTIME = the time for the first sample returned in
%                               data (in clock ticks)
%                    DATA = the output data array
%
% Alternative call:
% [npoints, bTime]=SONGETREALDATA(fh, chan,...
%               data, sTime, eTime{, FilterMask})
% Here, DATA must be a pre-allocated int16 column vector. SON32.DLL will
% place data directly into this array in the matlab workspace. For repeated
% calls, this can be faster but it breaks normal matlab conventions.
%
% For error codes returned in NPOINTS see the CED documentation
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London



