classdef pspm_get_labchartmat_in_test < pspm_get_superclass
% SCR_GET_LABCHARTMAT_IN_TEST 
% unittest class for the pspm_get_labchartmat_in function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus Rüttimann (University of Zurich)
       
    properties
        testcases;
        fhandle = @pspm_get_labchartmat_in;
        datatype = 'labchartmat_in';
        blocks = true;
    end
    
    methods
        function define_testcases(this)
            %testcase 1
            %--------------------------------------------------------------
            this.testcases{1}.pth = 'ImportTestData/labchart/LabChartMat_in_allchannels.mat';
            this.testcases{1}.numofblocks = 2;
            
            %The channels are technically emg channels. Since there are no other
            %sample files available at the moment, they are treated as scr
            %channels here
            this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 1);
            this.testcases{1}.import{2} = struct('type', 'scr'   , 'channel', 2);
            this.testcases{1}.import{3} = struct('type', 'scr'   , 'channel', 3);
            this.testcases{1}.import{4} = struct('type', 'scr'   , 'channel', 4);
            
             
        end
    end
    
    methods (Test)
        function invalid_datafile(this)
            fn = 'ImportTestData/labchart/LabChartMat_in_allchannels.mat';
            
            import{1} = struct('type', 'scr'   , 'channel', 1);
            import{2} = struct('type', 'scr'   , 'channel', 2);
            import{3} = struct('type', 'scr'   , 'channel',15);
            
            import = this.assign_chantype_number(import);
            
            this.verifyWarning(@()pspm_get_labchartmat_in(fn, import), 'ID:channel_not_contained_in_file');
        end
        
    end

end

