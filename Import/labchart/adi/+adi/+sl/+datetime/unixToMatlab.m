function matlab_time = unixToMatlab(unix_time,utc_offset)
%unixTimeToMatlabTime  Converts unix time to Matlab time
%   
%   matlab_time = sl.datetime.unixToMatlab(unix_time,*utc_offset)
%
%   INPUTS
%   =======================================================================
%   unixTime - (element or vector), unix time, # of non-leap seconds since 
%               January 1, 1970
%
%   OPTIONAL INPUTS
%   =======================================================================
%   utc_offset - (default, use local), -5 corresponds to EST
%   
%   OUTPUTS
%   =======================================================================
%   matlab_time - double, fraction represents seconds, the integer part of
%                the #, floor(matlabTime) represents the # of days since A.D.
%
%   See Also:
%   sl.datetime.getTimeZone


if ~exist('utc_offset','var') || isempty(utc_offset)
    utc_offset = adi.sl.datetime.getTimeZone;
end

SECONDS_IN_DAY = 86400;
UNIX_EPOCH     = 719529;
matlab_time     = unix_time./SECONDS_IN_DAY + UNIX_EPOCH + utc_offset/24; 