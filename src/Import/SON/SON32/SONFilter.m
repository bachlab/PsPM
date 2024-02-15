% SONFILTER tests whether a set of markers are included in the set defined
% by a filter mask
% 
% Implemented though SONFilter.dll
% 
% ANS=SONFILTER(MARKERS, FILTERMASK)
%
% INPUTS: MARKERS is EITHER
%             1. a TMarker structure as defined in the SON system
%               or
%             2. a 4-byte uint8 vector containing the marker values
%         FILTERMASK is the filter mask structure
% OUTPUTS: 1= the markers are included in the filter mask,
%                  0 otherwise
%                  
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London