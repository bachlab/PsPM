function [fn] = pspm_find_free_fn(fname, ext)
%% pspm_find_fn
% -------------------------------------------------------------------------
% class responsible to look for filenames which are not yet taken
% _________________________________________________________________________
% PsPM TestEnvironment
% (C) 2015 Tobias Moser (University of Zurich)

% $Id: pspm_find_free_fn.m 377 2016-10-31 15:57:10Z tmoser $
% $Rev: 377 $

i = 1;
fn = [fname,  num2str(i), ext];
while exist(fn, 'file')
    i = i+1;
    fn = [fname,  num2str(i), ext];
end;