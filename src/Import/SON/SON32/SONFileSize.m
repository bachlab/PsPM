function bytes=SONFileSize(fh)
% SONFILESIZE Returns the expected size of a file
%    BYTES=SONFILESIZE(FH) where FH is the file handle
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
             

bytes=calllib('son32','SONFileSize',fh);
return;