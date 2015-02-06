function ret=SONWriteMarkBlock(fh, chan, buffer, count)
% SONWRITEMARKBLOCK writes data to a marker channel
% 
% Implemented through SONWriteMarkBlock.dll
%
% RET=SONWRITEMARKBLOCK(FH, CHAN, TIMESTAMPS, MARKERS, COUNT)
% INPUTS: FH the SON file handle
%         CHAN the target channel
%         TIMESTAMPS a vector of int32 timestamps for the markers
%                   which should be at least COUNT in length
%         MARKERS the 4xCOUNT array of uint8 marker values, one set of
%                   4 for each timestamp
%         COUNT the number of marker items to write to the buffer
%         
% Returns zero or a negative error code.
% 
% For efficient use of disc space, COUNT should be  a multiple of 
% (BUFSIZE bytes - 20)/4 , where BUFSIZE is supplied in a prior call to
% SONSETEVENTCHAN (20 is the size of the block header on disc)
% 
% see CED documentation
% 
% See also SONSETEVENTCHAN, SONWRITEEVENTBLOCK, SONWRITEEXTMARKBLOCK
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London