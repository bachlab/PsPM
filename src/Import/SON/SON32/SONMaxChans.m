function n=SONMaxChans(fh)
% SONMAXCHANS returns the  number of channels supported by a SON file
% 
% N=SONMAXCHANS(FH)
% where FH is the SON file handle
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

n=calllib('son32','SONMaxChans',fh);

