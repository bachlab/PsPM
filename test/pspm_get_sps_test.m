classdef pspm_get_sps_test < matlab.unittest.TestCase
% SCR_GET_SPIKE_TEST 
% unittest class for the pspm_get_sps_test function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus R�ttimann (University of Zurich)
        
    methods (Test)
        function invalid_eye(this)
            
            import.sr = 100;
            import.data = ones(1,1000);
            import.units = 'degree';
            import.range = [ 0, 1];            

            this.verifyWarning(@() pspm_get_sps(import, 'not_an_eye'), 'ID:invalid_input');

            [ sts, out ] = this.verifyWarningFree(@() pspm_get_sps(import));
            this.verifyEqual(sts, 1);
            this.verifyEqual(out.header.chantype, 'sps');

            [ sts, out ] = this.verifyWarningFree(@() pspm_get_sps(import, 'l'));
            this.verifyEqual(sts, 1);
            this.verifyEqual(out.header.chantype, 'sps_l');

            [ sts, out ] = this.verifyWarningFree(@() pspm_get_sps(import, 'r'));
            this.verifyEqual(sts, 1);
            this.verifyEqual(out.header.chantype, 'sps_r');


            %  test partial application
            sps_l = @(x) pspm_get_sps(x, 'l');
            [ sts, out ] = this.verifyWarningFree(@() sps_l(import));
            this.verifyEqual(out.header.chantype, 'sps_l');

        end
        
    end
    
end

