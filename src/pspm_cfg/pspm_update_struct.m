function StructY = pspm_update_struct(StructY, StructX, Field)
if isfield(StructX, Field)
	FieldValue = getfield(StructX, Field);
	StructY = setfield(StructY, Field, FieldValue);
end
end
