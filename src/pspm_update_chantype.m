function [chantype_new] = pspm_update_chantype (chantype_og,keyword)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
chantype_new = chantype_og;
chantype_og_struct = split(chantype_og, '_');
chantype_new_struct = split(chantype_new, '_');
switch keyword
  case 'c'
    loc = strcmp(chantype_og_struct,'l') || strcmp(chantype_og_struct,'r');
    chantype_new_struct{loc} = 'c';
  case 'pp'
    chantype_new_struct = {chantype_og_struct{1}, 'pp', chantype_og_struct{2:end}};
end
chantype_new = join(chantype_new_struct,'_');
chantype_new = chantype_new{1};
end