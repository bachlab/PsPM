function str = join(cellstr_input,varargin)
%toString
%
%   str = sl.cellstr.join(cellstr_input,varargin)
%
%   INPUTS
%   =======================================================================
%   cellstr   : A cell array of strings to combine.
%   
%   OPTIONAL INPUTS
%   =======================================================================
%   d            : (default ','), delimiter string to use in combining strings
%   
%       To treat a delimiter as a literal escape the backlash with a
%       backlash. For example, this '\\t' will join strings with '\t'
%       instead of a tab. Percents should be escaped with a percent.
%   
%       The final delimiter => sprintf(delim)
%
%   remove_empty : (default false), if true empty values are removed
%   
%   EXAMPLES
%   =======================================================================
%
%   TODO: Finish Documentation

in.d        = ',';
in.remove_empty = false;
in = adi.sl.in.processVarargin(in,varargin);

if isempty(cellstr_input)
    str = '';
elseif ~iscell(cellstr_input)
    error('Input to %s must be a cell array',mfilename)
else
    P = cellstr_input(:)';
    if in.remove_empty
       P(cellfun('isempty',P)) = []; 
       if isempty(P)
          str = '';
          return
       end
    end
    P(2,:) = {sprintf(in.d)} ;  %Added on printing to handle things like \t and \n
    
    P{2,end} = [] ;
    str = sprintf('%s',P{:});
end