classdef table < dataset
    % Simple class for making modern table-based matlab code compatible
    % with pre 2013b versions (that have the Statistical Analysis Toolbox).
    %
    %   In MATLAB version 2013b, MathWorks introduced the builtin 'table'
    %   datatype, which superceded the 'dataset' type that was part of the
    %   Statistical Analysis Toolbox. As such, code using tables cannot run
    %   on pre 2013b MATLAB version, even though table and dataset types
    %   are very similar. This class, called 'table', subclasses the
    %   dataset type, and remaps the 'Properties' subscripts by overloading
    %   the 'subsref' and 'subsasgn' methods. This allows the 'dataset'
    %   type to be used with 'table' syntax.
    %
    %   Do not use this class when running MATLAB versions newer than
    %   2013b.
    %
    %   Note, this class is only meant for allowing the Pupil Preprocessing
    %   code to run in older MATLAB versions, not all features of the table
    %   class have been implemented.
    %
    %   - Elio Sjak-Shie, 2018. Leiden University.
    %
    %----------------------------------------------------------------------
    
    
    %% Properties:
    
    properties (Constant)
        
        % Term correction table:
        syntaxMap = ......
            ...
            ...NEW (table-style):      OLD (dataset-style):
            ...
            {'VariableDescriptions'    'VarDescription' ...
            ;'VariableUnits'           'Units' ...
            ;'VariableNames'           'VarNames' ...
            ;'RowNames'                'ObsNames' ...
            ;'DimensionNames'          'DimNames' ...
            ;'VariableDescriptions'    'VarDescription' ...
            ...
            };
        
    end
    
    
    %% Methods:
    
    methods
        
        
        %==================================================================
        function obj = table(varargin)
            % Constructor. This method constructs a "table" instance, which
            % is really a dataset.
            
            % Remap the table-style 'VariableNames' param to the
            % dataset-style 'VarNames':
            namesSpec = cellfun(@(c) isequal(c,'VariableNames')...
                ,varargin);
            if any(namesSpec)
                varargin(namesSpec) = {'VarNames'}; 
            end
            
            % Call superclass constructor:
            obj = obj@dataset(varargin{:});
            
            % If the variable names were not explicitely specified, try to
            % use the inputnames to name the variables. This is necessary
            % because the input names are not exposed to the dataset
            % constructor via the superclass call above:
            if ~any(namesSpec)
                inputNames = arrayfun(@inputname,1:nargin...
                    ,'UniformOutput',false);
                nonEmptyNames = ~cellfun(@isempty,inputNames);
                obj = subsasgn(obj,struct('type',{'.' '.' '()'},'subs'...
                    ,{'Properties' 'VarNames' {find(nonEmptyNames)}})...
                    ,inputNames(nonEmptyNames));
                
            end
            
        end
        

        %==================================================================
        function a = subsasgn(a,s,c)
            % Subscripted assignment overload.
            
            a = subsasgn@dataset(a,table.searchAndReplace(s),c);
            
        end
        
        
        %==================================================================
        function out = subsref(a,s)
            % Subscripted reference overload.
            
            out = subsref@dataset(a,table.searchAndReplace(s));
            
        end
        
    end
    
    
    methods (Static)
        
        
        %==================================================================
        function s = searchAndReplace(s)
            % Fixes certain syntactic incompatibilities between dataset and
            % table, so that the prior can be called with the latter's
            % Properties' fieldnames.
            
            % Check if the Properties prop was querried, if so, search and
            % replace the terms using the current class' syntaxMap
            % property, which maps table fieldnames onto dataset
            % fieldnames:
            if strcmp(s(1).type,'.') && strcmp(s(1).subs,'Properties')
                for curTerms = table.syntaxMap'
                    if numel(s) >= 2 && strcmp(s(2).subs,curTerms{1})
                        s(2).subs = curTerms{2};
                    end
                end
            end
            
        end
        
    
    end
    
end
