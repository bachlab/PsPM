function StructY = pspm_update_struct(StructY, StructX, Fields)
if ~exist('StructY','var')
  StructY = struct();
end
if ~iscell(Fields)
  Fields = {Fields};
end
for iField = 1:length(Fields)
	Field = Fields{iField};
	if isfield(StructX, Field)
		FieldValue = getfield(StructX, Field);
		StructY = setfield(StructY, Field, FieldValue);
	end
end
end
