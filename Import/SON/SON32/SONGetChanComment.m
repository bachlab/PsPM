function [comment]=SONGetChanComment(fh, chan)
% SONGETCHANCOMMENT returns the comment string for the specified channel
%
% COMMENT=SONGETCHANCOMMENT(FH, CHAN)
%                         FH SON file handle
%                         CHAN Channel number (0 to SONMAXCHANS-1)
% Returns the channel comment as a string.  
% 
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

global SON_CHANCOMSZ;

comment=char(zeros(1,SON_CHANCOMSZ));
comment=calllib('son32','SONGetChanComment',...
                        fh,chan,comment,SON_CHANCOMSZ);
