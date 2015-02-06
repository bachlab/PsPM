% Reads, sets or clears specified bits in a filter mask structure
% 
% Implemented through SONFControl.dll
% 
% [VAL FILTERMASK]=SONFCONTROL(FILTERMASK, LAYER, ITEM, ACTION)
% 
% INPUTS: FILTERMASK, filter mask structure
%         LAYER, the layer to change (0 to 3) or 'ALL' for  all layers
%         ITEM, the item to read or change (0 to 255) or 'ALL' for all items
%         ACTION the action to take 'READ', 'SET', 'CLEAR' or 'INVERT'.
%  
% OUTPUTS: VAL
%             For a read: set to the state of the item or, if LAYER or ITEMS
%             are 'ALL' set to 1 if all set and 0 if all are cleared
%             For a write: returns 0 or a negative error
%             FILTERMASK is a copy of the input filter with the required bits
%             set, cleared or inverted.
%
% N.B. any non-numeric input is assumed to represent 'ALL' above. For
% string inputs only the first character is used.
% 
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
 