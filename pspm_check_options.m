function [sts] = pspm_check_options(type, check_opt, fields)
% pspm_check_options is a helper function for other functions which should
% check optional input fields.
%
%   FORMAT:
%       type:               [string] What type of field is it:
%                           'string', 'numeric', 'cell', 'logical'
%
%       check_opt:          [struct] options which should be checked
%       fields:             [cell of strings] fields which should be
%                           checked
%__________________________________________________________________________
% PsPM 3.1
% (C) 2009-2016 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

n_errors = 0;
for f = 1:numel(fields)
  fl = fields{f};
  if ~isfield(check_opt, fl)
    warning('ID:invalid_input', 'Field ''%s'' does not seem to exist.', fl);
    n_errors = n_errors + 1;
  else
    val = getfield(check_opt, fl);
    switch type
      case 'string'
        if ~ischar(val)
          warning('ID:invalid_input', ['Field ''' fl ''' must be a string.']);
          n_errors = n_errors + 1;
        end;
      case 'numeric'
        if ~isnumeric(val)
          warning('ID:invalid_input', ['Field ''' fl ''' must be numeric.']);
          n_errors = n_errors + 1;
        end;
      case 'cell'
        if ~iscell(val)
          warning('ID:invalid_input', ['Field ''' fl ''' must be a cell.']);
          n_errors = n_errors + 1;
        end;
      case 'logical'
        if ~islogical(val) && ~(isnumeric(val) && any(val == [0 1]))
          warning('ID:invalid_input', ['Field ''' fl ''' must be a logical.']);
          n_errors = n_errors + 1;
        end;
    end;
  end;
end;

if n_errors == 0
  sts = 1;
end;

end
