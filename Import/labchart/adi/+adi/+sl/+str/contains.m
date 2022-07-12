function flag = contains(input_string,string_to_match,varargin)
%
%   sl.str.contains(s1,str_to_match,varargin)
%
%   Checks if one string can be found in another string.
%
%   Inputs:
%   -------
%   input_string: char
%   string_to_match: char
%
%   Optional Inputs:
%   ----------------
%   location: (default 'anywhere'
%       - 'start'
%       - 'end'
%       - 'anywhere'
%
%   Examples:
%   ----------
%   >> sl.str.contains('testing','ing','location','end')
%     ans = 1
%
%   >> sl.str.contains('testing','est','location','anywhere')

in.case_sensitive = true;
in.location = 'anywhere';
in = adi.sl.in.processVarargin(in,varargin);

switch in.location
    case 'start'
        if in.case_sensitive
            flag = strncmp(input_string,string_to_match,length(string_to_match));
        else
            flag = strncmpi(input_string,string_to_match,length(string_to_match));
        end
    case 'end'
        length_str = length(string_to_match);
        if length(input_string) < length_str
            flag = false;
        else
            if in.case_sensitive
                flag = strcmp(input_string((end-length_str+1):end),string_to_match);
            else
                flag = strcmpi(input_string((end-length_str+1):end),string_to_match);
            end
        end
    case 'anywhere'
        if in.case_sensitive
            flag = any(strfind(input_string,string_to_match));
        else
            %I had considered using regexpi but then I need to worry about
            %translating the string to match 
            %flag = any(regexpi(input_string,regexptranslate(string_to_match),'match','once')
            flag = any(strfind(lower(input_string),lower(string_to_match)));
        end
    otherwise
        error('Unrecognized option for string match: %s',in.location);
end

end

%{

%Testing end match
sl.str.contains('testing','ing','location','end')

%String too long
sl.str.contains('testing','asdfasdfing','location','end')

%Testing start
sl.str.contains('testing','test','location','start')

%Middle match
sl.str.contains('testing','est','location','anywhere')


%}