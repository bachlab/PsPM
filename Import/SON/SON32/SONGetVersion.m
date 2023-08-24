function version=SONGetVersion(fh)
% SONGETVERSION returns the SON file system version number for a file
%
% VERSION=SONGETVERSION(FH)
% where fh is the SON File handle
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

version=calllib('son32', 'SONGetVersion', fh);