function StructY = pspm_update_struct(StructY, StructX, Fields)
switch length(Fields)
case 1
	if isfield(StructX, Fields)
		FieldValue = getfield(StructX, Fields);
		StructY = setfield(StructY, Fields, FieldValue);
	end
otherwise
	for iField = 1:length(Fields)
		Field = Fields{iField};
		if isfield(StructX, Field)
			FieldValue = getfield(StructX, Field);
			StructY = setfield(StructY, Field, FieldValue);
		end
	end
end
end
