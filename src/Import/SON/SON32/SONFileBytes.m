function bytes=SONFileBytes(fh)
% SONFILEBYTES Returns the number of bytes in the file 
%    BYTES=SONFILEBYTES(FH) where FH is the file handle
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
             

bytes=calllib('son32','SONFileBytes',fh);
return;