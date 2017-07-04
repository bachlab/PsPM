function str = showdetail(item)

% function str = showdetail(item)
% Display details for a cfg_exbranch and all of its options.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: showdetail.m 380 2016-11-08 07:47:23Z tmoser $

rev = '$Rev: 380 $'; %#ok

str = showdetail(item.cfg_branch);
str{end+1} = 'Class  : cfg_exbranch';
str{end+1} = 'Functions associated with this item:';
% Display details about function handles
str{end+1} = sprintf('.prog  : %s', func2str(item.prog));
if ~isempty(item.vout)
    str{end+1} = sprintf('.vout  : %s', func2str(item.vout));
elseif ~isempty(item.vfiles)
    str{end+1} = sprintf('.vfiles: %s', func2str(item.vfiles));
end
