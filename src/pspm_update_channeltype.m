function [channeltype_new] = pspm_update_channeltype (channeltype_og, keyword)
% ● Description
%   pspm_update_channeltype update the keywords of channel type
% ● Arguments
%   channeltype_og:  [string] the name of the original channel type
%       keyword:  the keyword to update to
%                 accepted values, 'c', 'pp', or {'c','pp'}
%                 'c': update the lateral keyword 'l' or 'r' to 'c'
%                 'pp': update the channel type to be preprocessed
%                 {'c','pp'}: update the channel type to be both bilateral
%                 and preprocessed.
% ● Output
%   channeltype_new: the new channel type with the updated keyword
% ● History
%   Introduced in PsPM 6.0.
%   Written in 2022 by Teddy Chao (UCL)

channeltype_new = channeltype_og;
channeltype_og_struct = split(channeltype_og, '_');
channeltype_new_struct = split(channeltype_new, '_');
switch class(keyword)
  case 'char'
    switch keyword
      case 'c'
        loc = strcmp(channeltype_og_struct,'l') + strcmp(channeltype_og_struct,'r');
        channeltype_new_struct{logical(loc)} = 'c';
      case 'pp'
        if ~strcmp(channeltype_og_struct,'pp')
          channeltype_new_struct = {channeltype_og_struct{1}, 'pp', channeltype_og_struct{2:end}};
        end
    end
  otherwise
    % if keyword is {'c','pp'}
    if isempty(setdiff(keyword, {'c','pp'})) || isempty(setdiff(keyword, {'pp','c'}))
      loc = strcmp(channeltype_og_struct,'l') + strcmp(channeltype_og_struct,'r');
      channeltype_new_struct{logical(loc)} = 'c';
      if ~strcmp(channeltype_og_struct,'pp')
        channeltype_new_struct = {channeltype_new_struct{1}, 'pp', channeltype_new_struct{2:end}};
      end
    end
end
channeltype_new = join(channeltype_new_struct,'_');
channeltype_new = channeltype_new{1};
end