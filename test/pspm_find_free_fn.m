function [fn] = pspm_find_free_fn(fname, ext)
%% pspm_find_fn
% -------------------------------------------------------------------------
% class responsible to look for filenames which are not yet taken
% _________________________________________________________________________
% PsPM TestEnvironment
% (C) 2015 Tobias Moser (University of Zurich)

i = 1;
fn = [fname,  num2str(i), ext];
while exist(fn, 'file')
  i = i+1;
  fn = [fname,  num2str(i), ext];
end