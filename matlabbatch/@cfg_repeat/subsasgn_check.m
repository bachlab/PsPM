function [sts, val] = subsasgn_check(item,subs,val)

% function [sts, val] = subsasgn_check(item,subs,val)
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: subsasgn_check.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok
sts = true;
switch subs(1).subs
    case {'num'}
        sts = subsasgn_check_num(val);
    case {'values'}
        sts = ~cfg_get_defaults('cfg_item.checkval') || subsasgn_check_valcfg(subs,val,[0 Inf]);
    case {'val'}
        % Check maximum number of elements - don't limit minimum number
        sts = ~cfg_get_defaults('cfg_item.checkval') || subsasgn_check_valcfg(subs,val,[0 item.num(2)]);
        % Could also check whether added element is one from 'values' list
end;
