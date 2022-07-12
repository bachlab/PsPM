function fh=SONCreateFile(filename, nChan, extra)
% SONCREATEFILE creates a new SON file
%     FH=SONCREATEFILE(FILNAME, NCHANS, EXTRA)
%         FILENAME = string wiht file and path
%         NCHAN = number of channels 32 to 256
%         EXTRA = number of bytes to reserve for user specified data
%             area in the file header.
% Returns FH, a file handle or a negative error code
% 
% This function replaces SONOpenNewFile
% See also SONOPENNEWFILE
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

fh=calllib('son32','SONCreateFile',filename, nChan, extra);
return;
