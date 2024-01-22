function ret=SONUpdateStart(fh)
% SONUPDATESTART flushes the SON file header to disc
% 
% RET=SONUPDATESTART(FH)
% where FH is the SON file handle
%
% Returns zero or a negative error
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

ret=calllib('son32', 'SONUpdateStart', fh);