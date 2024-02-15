function interleave=SONChanInterleave(fh, chan)
% SONCHANINTERLEAVE Returns the channel interleave factor for ADCMark channels
% in SON V6 or above
% INTERLEAVE=SONCHANINTERLEAVE(FH, CHAN)
%                         FH SON File Handle
%                         Chan Channel number
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London   


interleave=calllib('son32','SONChanInterleave',fh, chan);
return;
