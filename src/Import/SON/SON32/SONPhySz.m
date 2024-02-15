function buffsize=SONPhySz(fh, chan)
% SONPHYSZ returns the buffer size for the specified chanel
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

buffsize=calllib('son32','SONPhySz', fh, chan);
