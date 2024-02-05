function StructY = pspm_update_struct(StructY, StructX, Fields)
% ● Description
%   pspm_update_struct can transfer the values of specific Fields from one
%   struct StructX to another struct StructY.
% ● Format
%   StructY = pspm_update_struct(StructY, StructX, Fields)
% ● Arguments
%   StructX: the struct that has fields to be transfered from
%   StructY: the struct that will receive fields
%   Fields:  the cell array that has the fields to be detected and
%            transferred. It can be just a string if there is only one
%            field to be transferred.
% ● History
%   Written in 05-02-2024 by Teddy
if ~exist('StructY','var')
  StructY = struct();
end
if ~iscell(Fields)
  Fields = {Fields};
end
for iField = 1:length(Fields)
	Field = Fields{iField};
	if isfield(StructX, Field)
		StructY.(Field) = StructX.(Field);
	end
end
end
