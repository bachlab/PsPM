function [chantype_new] = pspm_update_chantype (chantype_og,keyword)
% ● Description
%   pspm_update_chantype update the keywords of channel type
% ● Arguments
%   chantype_og:  [string] the name of the original channel type
%       keyword:  the keyword to update to
%                 accepted values, 'c', 'pp', or {'c','pp'}
%                 'c': update the lateral keyword 'l' or 'r' to 'c'
%                 'pp': update the channel type to be preprocessed
%                 {'c','pp'}: update the channel type to be both bilateral
%                 and preprocessed.
% ● Output
%   chantype_new: the new channel type with the updated keyword
% ● History
%   Introduced in PsPM 6.0.
%   Written in 2022 by Teddy Chao (UCL)

chantype_new = chantype_og;
chantype_og_struct = split(chantype_og, '_');
chantype_new_struct = split(chantype_new, '_');
switch class(keyword)
  case 'char'
    switch keyword
      case 'c'
        loc = strcmp(chantype_og_struct,'l') + strcmp(chantype_og_struct,'r');
        chantype_new_struct{logical(loc)} = 'c';
      case 'pp'
        if ~strcmp(chantype_og_struct,'pp')
          chantype_new_struct = {chantype_og_struct{1}, 'pp', chantype_og_struct{2:end}};
        end
    end
  otherwise
    % if keyword is {'c','pp'}
    if isempty(setdiff(keyword, {'c','pp'})) || isempty(setdiff(keyword, {'pp','c'}))
      loc = strcmp(chantype_og_struct,'l') + strcmp(chantype_og_struct,'r');
      chantype_new_struct{logical(loc)} = 'c';
      if ~strcmp(chantype_og_struct,'pp')
        chantype_new_struct = {chantype_new_struct{1}, 'pp', chantype_new_struct{2:end}};
      end
    end
end
chantype_new = join(chantype_new_struct,'_');
chantype_new = chantype_new{1};
end