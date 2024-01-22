% SONAPPID sets or gets the creator lable from a SON file
%
% Implemented through SONAppID.dll
%
%     LABLE=SONAPPID(FH)
%     returns the creator lable
%     LABLE2=SONAPPID(FH, LABLE2)
%     sets the lable to LABLE2 then reads it back to LABLE1
% 
%         FH is the SON file handle
%         LABLE, LABLE1 etc are MATLAB strings.
%           Only the first 8 characters will be used.
%
% Returns no errors
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London 