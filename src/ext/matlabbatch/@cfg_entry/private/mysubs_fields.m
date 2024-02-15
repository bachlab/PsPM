function [fnames, defaults] = mysubs_fields

% function [fnames, defaults] = mysubs_fields
% Additional fields for class cfg_entry. See help of
% @cfg_item/subs_fields for general help about this function.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: mysubs_fields.m 380 2016-11-08 07:47:23Z tmoser $

rev = '$Rev: 380 $'; %#ok

fnames = {'strtype','num','extras'};
defaults = {'e',[],{}};