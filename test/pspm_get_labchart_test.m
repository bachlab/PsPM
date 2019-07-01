classdef pspm_get_labchart_test < pspm_get_superclass
% SCR_GET_LABCHARTMAT_TEST 
% unittest class for the pspm_get_labchart function
%__________________________________________________________________________
% PsPM TestEnvironment
% (C) 2017 Tobias Moser (University of Zurich)
       
    properties
        testcases;
        fhandle = @pspm_get_labchart;
    end
    
    methods
        function define_testcases(this)
            %testcase 1
            %--------------------------------------------------------------
            this.testcases{1}.pth = 'ImportTestData/labchart/Sample_GSR_data.adicht';
            
            this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 1);
            this.testcases{1}.import{2} = struct('type', 'marker', 'channel', 0);             
        end
    end
    
    methods (Test)
        function invalid_datafile(this)
            fn = 'ImportTestData/labchart/Sample_GSR_data.adicht';
            
            import{1} = struct('type', 'scr'   , 'channel', 1);
            import{2} = struct('type', 'scr'   , 'channel', 5);
            import{3} = struct('type', 'marker', 'channel', 0);
            
            import = this.assign_chantype_number(import);
            
            this.verifyWarning(@()pspm_get_labchart(fn, import), 'ID:channel_not_contained_in_file');
        end
        
    end

end
