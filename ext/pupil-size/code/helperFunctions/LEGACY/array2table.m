function DSout = array2table(arrayIn)
% Helper function for table spoofing.
%
% Technical note: the input names are not passed through to the dataset
% constructor for variable naming.

% Force the constuction of the legacy table datatype, which is a dataset
% subclass compatible with the table syntax:
args  = num2cell(arrayIn,1);
DSout = table(args{:});

end
