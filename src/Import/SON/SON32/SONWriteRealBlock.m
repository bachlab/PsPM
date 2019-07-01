function ret=SONWriteRealBlock(fh, chan, buffer, count, startTime)
% SONWRITERealBLOCK writes data to an Real channel
% 
% RET=SONWRITERealBLOCK(FH, CHAN, BUFFER, COUNT, STARTTIME)
% INPUTS: FH the SON file handle
%         CHAN the target channel
%         BUFFER the data to be written (single floating point)
%         COUNT the number of data items to write from buffer
%         STARTTIME the time of the first sample in buffer (in clock ticks)
%         
% RET is the time for the next sample to be supplied in a subsequqnt call to
% SONWRITERealBLOCK (assuming continuous sampling) or a negative error code.
% 
% Fo efficient use of disc space, COUNT should be  a multiple of 
% (BUFSIZE - 20 bytes)/4 , where BUFSIZE is supplied in a prior call to
% SONSETRealCHAN (20 is the size of the block header on disc)
% 
% see CED documentation
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

if (strcmp(class(buffer),'single'))
    ret=calllib('son32','SONWriteRealBock',...
        fh, chan, buffer, count, startTime);
else
    ret=-22;