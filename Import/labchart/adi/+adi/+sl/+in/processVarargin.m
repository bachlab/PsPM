function [in,extras] = processVarargin(in,v,varargin)
%processVarargin  Processes varargin and overrides defaults
%
%   Function to override default options.
%
%   [in,extras] = sl.in.processVarargin(in,v,varargin) 
%
%   INPUTS
%   =======================================================================
%   in       : structure containing default values that may be overridden
%              by user inputs
%   v        : varargin input from calling function, prop/value pairs or 
%              structure with fields
%
%   varargin : see optional inputs, prop/value or structure with fields
%
%   OPTIONAL INPUTS (specify via prop/value pairs or struct)
%   =======================================================================
%   Rules for these are:
%   - case insensitive
%   - non-matches not allowed ...
%
%   case_sensitive    : (default false)
%   allow_non_matches : (default false)
%
%
%   %   allow_duplicates  : (default false) NOT YET IMPLEMENTED
%   partial_match     : (default false) NOT YET IMPLEMENTED
%
%   OUTPUTS
%   =======================================================================
%   extras : Class: sl.in.process_varargin_result
%
%   TODO: Provide link
%   EXAMPLES
%   =======================================================================
%   1)
%   function test(varargin)
%   in.a = 1
%   in.b = 2
%   in = processVarargin(in,varargin,'allow_duplicates',true)
%
%   Similar functions:
%   http://www.mathworks.com/matlabcentral/fileexchange/22671
%   http://www.mathworks.com/matlabcentral/fileexchange/10670
%
%   IMPROVEMENTS
%   =======================================================================
%   1) For non-matched inputs, provide link to offending caller
%
%
%   See Also:
%   sl.in.tests.processVarargin



%Check to exit code quickly when it is not used ...
if isempty(v) && nargout == 1
    %Possible improvement
    %- provide code that allows this to return quicker if nargout == 2
    return
end

c.case_sensitive    = false;
% % % c.allow_duplicates  = false;
% % % c.partial_match     = false;
c.allow_non_matches = false;
c.allow_spaces      = true;


%Update instructions on how to parse the optional inputs
%--------------------------------------------------------------------------
%This type of code would allow a bit more flexibility on how to process 
%the processing options if we ever decided they needed to be different
%
%
% c2 = c;
% c2.case_sensitive = false;
%
%NOTE: If we don't pass in any instructions on how to parse the data
%differently we can skip this step ...
if ~isempty(varargin)
    %Updates c based on varargin from user 
    %c = processVararginHelper(c,varargin,c2,1);
    c = processVararginHelper(c,varargin,c,true);
end

%Update optional inputs of calling function with this function's options now set
[in,extras] = processVararginHelper(in,v,c,false);

end



function [in,extras] = processVararginHelper(in,v,c,is_parsing_options)
%processVararginHelper
%
%   [in,extras] = processVararginHelper(in,v,c,is_parsing_options)
%
%   This function does the actual work. It is a separate function because 
%   we use this function to handle the options on how this function should
%   work for the user's inputs. We use the same approach for the processing
%   options as we do the user's inputs.
%
%   INPUTS
%   =======================================================================
%   in - (structure input)
%   v  - varargin input, might be structure or prop/value pairs
%   c  - options for processing 
%   is_parsing_options - specifies we are parsing the parsing options

extras = adi.sl.in.process_varargin_result(in,v);

%Checking the optional inputs, either a structure or a prop/value cell
%array is allowed, or various forms of empty ...
if isempty(v)
    %do nothing
    parse_input = false;
elseif isstruct(v)
    %This case should generally not happen
    %It will if varargin is not used in the calling function
    parse_input = true;
elseif isstruct(v{1}) && length(v) == 1
    %Single structure was passed in as sole argument for varargin
    v = v{1};
    parse_input = true;
elseif iscell(v) && length(v) == 1 && isempty(v{1})
    %User passed in empty cell option to varargin instead of just ommitting input
    parse_input = false;
else
    parse_input = true;
    is_str_mask = cellfun('isclass',v,'char');
    
    %Improvement:
    %-------------------------------------------------
    %Analyze calling information ...
    %Provide stack trace for editing ...
    %
    %   Functions needed:
    %   1) prototype of caller
    %   2) calling format of parent
    %   3) links to offending lines ...
    %
    %   NOTE: is_parsing_options would allow us to have different 
    %   error messages ...
    if ~all(is_str_mask(1:2:end))
        error('Unexpected format for varargin, not all properties are strings')
    end
    if mod(length(v),2) ~= 0
        error('Property/value pairs are not balanced, length of input: %d',length(v))
    end
    
    if c.allow_spaces
       %strrep would be faster if we could guarantee
       %only single spaces :/
       v(1:2:end) = regexprep(v(1:2:end),'\s+','_');
    end
    
    v = v(:)'; %Ensure row vector 
    v = cell2struct(v(2:2:end),v(1:2:end),2);
end

if ~parse_input
   return 
end

extras.struct_mod_input = v;

%At this point we should have a structure ...
fn__new_values   = fieldnames(v);
fn__input_struct = fieldnames(in);
extras.fn__new_values   = fn__new_values;
extras.fn__input_struct = fn__input_struct;


%Matching location
%--------------------------------------------------------------------------
if c.case_sensitive
	[is_present,loc] = ismember(fn__new_values,fn__input_struct);
else
    [is_present,loc] = ismember(upper(fn__new_values),upper(fn__input_struct));
    %NOTE: I don't currently do a check here for uniqueness of matches ...
    %Could have many fields which case-insensitive are the same ...
end
extras.is_present = is_present;
extras.loc        = loc;

if ~all(is_present)
    if c.allow_non_matches
        %Lazy evaluation in result class
    else
        %NOTE: This would be improved by adding on the restrictions we used in mapping
        badVariables = fn__new_values(~is_present);
        error(['Bad variable names given in input structure: ' ...
            '\n--------------------------------- \n %s' ...
            ' \n--------------------------------------'],...
            adi.sl.cellstr.join(badVariables,'d',','))
    end
end

%Actual assignment
%---------------------------------------------------------------
for i = 1:length(fn__new_values)
    if is_present(i)
    %NOTE: By using fn_i we ensure case matching
    in.(fn__input_struct{loc(i)}) = v.(fn__new_values{i});
    end
end

end
