function bytes=SONGetExtraDataSize(fh)
% Returns the size of the extra data area of file FH in bytes
% 
% BYTES=SONGETEXTRADATASIZE(FH)
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

bytes=calllib('son32', 'SONGetExtraDataSize', fh);