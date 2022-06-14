function [chantype_new] = pspm_update_chantype (chantype_og,keyword)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
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