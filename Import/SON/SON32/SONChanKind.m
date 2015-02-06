function kind=SONChanKind(fh, chan)
% SONCHANKIND Returns the channel type 
%    KIND=SONCHANKIND(FH, CHAN) where FH is the file handle
%                               CHAN is the channel number (0 to
%                               SONMAXCHANS-1)
%   Returns kind as an enumerated string - see CED documentation for values
%   No errors returned
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
             

kind=calllib('son32','SONChanKind',fh, chan);
return;
