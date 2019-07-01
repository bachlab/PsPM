classdef pspm_get_biotrace_test < pspm_get_superclass
% SCR_GET_BIOTRACE_TEST 
% unittest class for the pspm_get_biotrace function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus Rüttimann (University of Zurich)
       
    properties
        testcases;
        fhandle = @pspm_get_biotrace;
    end
    
    methods
        function define_testcases(this)
            %testcase 1
            %--------------------------------------------------------------
            this.testcases{1}.pth = 'ImportTestData/biotrace/Biotrace_SCR.txt';
            
            this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 1);
            
            %testcase 2
            %--------------------------------------------------------------
            this.testcases{2}.pth = 'ImportTestData/biotrace/Biotrace_SCR_Marker.txt';
            
            this.testcases{2}.import{1} = struct('type', 'scr'   , 'channel', 1);
            this.testcases{2}.import{1} = struct('type', 'marker', 'channel', 0);
             
        end
    end   
    
end

