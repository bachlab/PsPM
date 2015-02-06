function fn = fieldnames(item)

% function fn = fieldnames(item)
% Return a list of all (inherited and non-inherited) field names.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: fieldnames.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok

fn1 = fieldnames(item.cfg_branch);
fn2 = mysubs_fields;

fn = [fn1(:); fn2(:)]';