function ret=SONWriteADCBlock(fh, chan, buffer, count, startTime)
% SONWRITEADCBLOCK writes data to an ADC channel
% 
% RET=SONWRITEADCBLOCK(FH, CHAN, BUFFER, COUNT, STARTTIME)
% INPUTS: FH the SON file handle
%         CHAN the target channel
%         BUFFER the data to be written (int16 ADC data)
%         COUNT the number of data items to write from buffer
%         STARTTIME the time of the first sample in buffer (in clock ticks)
%         
% RET is the time for the next sample to be supplied in a subsequqnt call to
% SONWRITEADCBLOCK (assuming continuous sampling) or a negative error code.
% 
% Fo efficient use of disc space, COUNT should be  a multiple of 
% (BUFSIZE - 20 bytes)/2 , where BUFSIZE is supplied in a prior call to
% SONSETADCCHAN (20 is the size of the block header on disc)
% 
% see CED documentation
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

if (strcmp(class(buffer),'int16'))
    ret=calllib('son32','SONWriteADCBock',...
        fh, chan, buffer, count, startTime);
else
    ret=-22;
