function utc_offset = getTimeZone
%getTimeZone  Returns the time zone of the operating system.
%
%   utc_offset = sl.datetime.getTimeZone
%
%   Uses a Java call. This function is necessary for converting between
%   Matlab time which is local based, and many other time codes which are
%   all UTC based.
%
%   OUTPUTS
%   =======================================================================
%   utc_offset : # of hours different from UTC the computer is. For
%           example, a computer using Eastern Standard Time will return -5


%Java call
tz = java.util.TimeZone.getDefault;  %in ms

%convert to hours
%1000 ms/s * 60 s/min * 60 min/hour
utc_offset = tz.getRawOffset/3600000;