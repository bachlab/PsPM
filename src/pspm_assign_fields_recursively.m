function out_struct = pspm_assign_fields_recursively(out_struct, in_struct)

% DEFINITION
% pspm_assign_fields_recursively assign all fields of in_struct to out_struct recursively, overwriting when necessary.
fnames = fieldnames(in_struct);
for i = 1:numel(fnames)
	name = fnames{i};
	if isstruct(in_struct.(name)) && isfield(out_struct, name)
		out_struct.(name) = pspm_assign_fields_recursively(out_struct.(name), in_struct.(name));
	else
		out_struct.(name) = in_struct.(name);
	end
end
end
