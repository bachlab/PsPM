classdef (Hidden) process_varargin_result < handle
    %
    %   Class:
    %   sl.in.process_varargin_result
    %
    %   This is a result class from running sl.in.processVarargin
    %
    %   See Also:
    %   sl.in.processVarargin
    
    %Inputs  ==============================================================
    properties
        d1 = '----  Inputs  -----'
        input_structure
        raw_mod_input  %The raw modification instructions ...
    end
    
    %The following may not be populated if the input is empty ...
    %Ideally they would have defaults that don't cause an error on display
    %...
    properties
        %   FORM:
        %      - []
        %      - struct
        %      - cell array with
        struct_mod_input = struct([])  %modification instructions as
        %a structure
    end
    
    properties (Hidden)
        fn__new_values   = {}
        fn__input_struct = {}
        
        %Result of ismember(new_values,original) 
        is_present
        loc
    end
    
    %Outputs ==============================================================
    properties (Hidden)
        %NOTE: Ideally we could use a lazy evaluator which
        %removed the get method after the first evaluation
        %so that the default retrieval would be used ... :/
        non_match_names_initialized             = false
        unmatched_args_as_cell_initialized  = false
        umatched_args_as_struct_initialized = false
        is_modified_initialized         = false
    end
    
    properties
        d2 = '----  Outputs ----'
        non_match_names   %(cellstr)
        umatched_args_as_cell       %(?rename)
        umatched_args_as_struct     %(?rename)
        is_modified
    end
    
    properties (Dependent)
       non_matches %alias of non_match_names - poor name choice :/ 
       %Might remove, not sure if anything was using this ...
    end
    
    %Lazy get methods =====================================================
    methods
        function value = get.non_matches(obj)
           value = obj.non_match_names;
        end
        function value = get.non_match_names(obj)
            if ~obj.non_match_names_initialized
                obj.non_match_names = obj.fn__new_values(~obj.is_present);
                obj.non_match_names_initialized = true;
            end
            value = obj.non_match_names;
        end
        function value = get.umatched_args_as_cell(obj)
            if ~obj.unmatched_args_as_cell_initialized
                s = obj.umatched_args_as_struct;
                
                not_matched_names = fieldnames(s);
                n_bad = length(not_matched_names);
                
                c = cell(1,n_bad*2);
                c(2:2:end) = struct2cell(s);
                c(1:2:end) = not_matched_names;
                obj.umatched_args_as_cell = c;
                
                obj.unmatched_args_as_cell_initialized = true;
            end
            value = obj.umatched_args_as_cell;
        end
        function value = get.umatched_args_as_struct(obj)
            if ~obj.umatched_args_as_struct_initialized
                obj.umatched_args_as_struct = rmfield(obj.struct_mod_input,obj.non_match_names);
                obj.umatched_args_as_struct_initialized = true;
            end
            value = obj.umatched_args_as_struct;
        end
        function value = get.is_modified(obj)
           if ~obj.is_modified_initialized
               fn_local = obj.fn__input_struct;
               n_fields = length(fn_local);
               
               changed_mask = false(1,n_fields);
               changed_mask(obj.loc(obj.is_present)) = true;
               
               obj.is_modified = cell2struct(num2cell(changed_mask),fn_local);
               obj.is_modified_initialized = true;
           end
           value = obj.is_modified;
        end
    end
    
    methods
        function obj = process_varargin_result(input_structure,raw_mod_input)
            obj.input_structure = input_structure;
            obj.raw_mod_input   = raw_mod_input;
        end
    end
    
end

