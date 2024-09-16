function sts = pspm_doc_gen(varargin)
% ● Description
%   pspm_doc_gen generates the documents of help text 
%   in pspm functions into markdown files.
% ● Format
%   sts = pspm_doc_gen()
%   sts = pspm_doc_gen({'pspm_dcm'})
%   sts = pspm_doc_gen('/Users/pspm/')
%   sts = pspm_doc_gen({'pspm_dcm'}, '/Users/pspm/')
% ● History
%   Introduced in PsPM 7.0
%   Written in 2024 by Teddy

global settings
if isempty(settings)
  pspm_init;
end
sts = 1;
switch nargin
  case 0
    savepath = [settings.path, '/markdown'];
    mkdir(savepath);
  case 1
    switch class(varargin{1})
      case 'char'
        savepath = varargin{1};
      case 'cell'
        savepath = [settings.path, '/markdown'];
        mkdir(savepath);
        list_func = varargin{1};
    end
  case 2
    list_func = varargin{1};
    savepath = varargin{2};
end
if ~exist('list_func', 'var')
  listing = dir(settings.path);
  list_func = transpose({listing.name});
  list_func = {list_func{logical(contains(list_func,'pspm_') .* endsWith(list_func,'.m'))}};
  list_func = {list_func{~contains(list_func,'pspm_get_timing.m')}};
  list_func = {list_func{~contains(list_func,'pspm_init.m')}};
end
for i_func = 1:length(list_func)
  options = struct();
  options.path = savepath;
  disp(list_func{i_func});
  sts_temp = pspm_doc(list_func{i_func}, options);
  if sts_temp == -1
    sts = -1;
  end
end
end