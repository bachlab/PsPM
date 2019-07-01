classdef pspm_get_hb_test < matlab.unittest.TestCase
% SCR_GET_HB_TEST 
% unittest class for the pspm_get_hb function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus Rüttimann (University of Zurich)

    methods (Test)
        function test(this)
            import.sr = 1;
            import.data = 1:10;
            import.marker = 'timestamps';
            
            [sts, data] = pspm_get_hb(import);
            
            this.verifyEqual(sts, 1);
            this.verifyEqual(data.data, import.data(:));
            this.verifyTrue(strcmpi(data.header.chantype, 'hb'));
            this.verifyTrue(strcmpi(data.header.units, 'events'));
            this.verifyEqual(data.header.sr, 1);
            
        end
    end
    
end

