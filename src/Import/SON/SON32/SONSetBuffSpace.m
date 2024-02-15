function ret=SONSetBuffSpace(fh)
% SONSETBUFFSPACE allocates buufer space for file writes
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

ret=calllib('son32','SONSetBuffSpace',fh);
