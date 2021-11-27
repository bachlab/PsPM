function eyestr = pspm_get_eye(var_chantype)
indices = strfind(var_chantype, '_');
if numel(indices) == 1
	begidx = indices(1) + 1;
	endidx = numel(var_chantype);
else
	begidx = indices(1) + 1;
	endidx = indices(2) - 1;
end
eyestr = var_chantype(begidx : endidx);
end
