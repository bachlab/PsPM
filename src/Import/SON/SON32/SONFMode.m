% SONFMODE creates a filter mask structure and/or 
% sets the mode for marker filtering
% 
% Implemented though SONFMode.dll
% 
% FILTERMASK=SONFMODE(MODE)
% FILTERMASK=SONFMODE(FILTERMASK, MODE)
%
% INPUTS: FILTERMASK, if present, is a filter mask structure that will be
%               copied to the output
%          MODE is a string, currently 'OR', 'AND' or 'NOCHANGE'
%               (not case sensitive) -
%               N.B. only the 1st letter is examined. If 'nochange' is 
%               set without an input filter mask, or no mode is specified,
%               'AND' mode is selected by default.
% OUTPUT: A FILTERMASK structure with flags set according to MODE. 
%           If a filter mask is provided on input, mask values will be
%           copied from it to the output mask filter.
%           
%                  
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London