% SONDATETIME gets or sets the creation data/time data in a SON file 
% The date/time are returned in standard MATLAB format
%
% Implemented through SONDateTime.dll
% 
% DATEVECTOR = SONDATETIME(FH)
%         returns the creation date/time from the file
% DATEVECTOR1 = SONDATETIME(FH, DATEVECTOR2)
%         sets the time/date field to DATAVECTOR2 then reads it back
%         to DATAVECTOR1 (which may be the same vector)
%      
%             FH is the SON file handle
%             DATEVECTOR is a 1x6 double vector as
%                returned by the MATLAB builtin CLOCK function
%
% If an error occurs, the returned vector will be filled with zeros.
%
% Note: the date/time field is available in SON files of Version 6 and higher
% only.
% 
% See also CLOCK, DATESTR
% 
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

