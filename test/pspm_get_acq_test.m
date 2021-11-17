classdef pspm_get_acq_test < pspm_get_superclass
% SCR_GET_MAT_TEST 
% unittest class for the pspm_get_mat function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus Rüttimann (University of Zurich)
       
    properties
        testcases;
        fhandle = @pspm_get_acq
    end
    
    methods
        function define_testcases(this)
            %testcase 1
            %--------------------------------------------------------------
            this.testcases{1}.pth = 'ImportTestData/acq/Acq_SCR.acq';
            
            this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 1);
            
            %testcase 2
            %--------------------------------------------------------------
            this.testcases{2}.pth = 'ImportTestData/acq/Acq_SCR_Marker.acq';
            
            this.testcases{2}.import{1} = struct('type', 'scr'   , 'channel', 1);
            this.testcases{2}.import{2} = struct('type', 'marker', 'channel', 2);
            
            %testcase 3
            %--------------------------------------------------------------
            this.testcases{3}.pth = 'ImportTestData/acq/Acq_ECG_SCR_Marker.acq';
            
            this.testcases{3}.import{1} = struct('type', 'ecg'   , 'channel', 1);
            this.testcases{3}.import{2} = struct('type', 'scr'   , 'channel', 2);
            this.testcases{3}.import{3} = struct('type', 'marker', 'channel', 3);
            
            %testcase 4 (with channel name search)
            %--------------------------------------------------------------
            this.testcases{4}.pth = 'ImportTestData/acq/Acq_ECG_SCR_Marker.acq';
            
            this.testcases{4}.import{1} = struct('type', 'ecg'   , 'channel', 0);
            this.testcases{4}.import{2} = struct('type', 'scr'   , 'channel', 0);
            this.testcases{4}.import{3} = struct('type', 'marker', 'channel', 0);
            
            %testcase 5
            %--------------------------------------------------------------
            this.testcases{5}.pth = 'ImportTestData/acq/Acq_various_channels.acq';
            
            this.testcases{5}.import{1} = struct('type', 'ecg'   , 'channel', 1);
            this.testcases{5}.import{2} = struct('type', 'scr'   , 'channel', 2);
            this.testcases{5}.import{3} = struct('type', 'marker', 'channel', 3);
            this.testcases{5}.import{4} = struct('type', 'hr'    , 'channel', 8);
            this.testcases{5}.import{5} = struct('type', 'scr'   , 'channel', 9);
            
            %testcase 6
            %--------------------------------------------------------------
            this.testcases{6}.pth = 'ImportTestData/acq/Acq_real_Breath_Hold.acq';
            
            this.testcases{6}.import{1} = struct('type', 'scr'   , 'channel', 3);
            this.testcases{6}.import{2} = struct('type', 'resp'  , 'channel', 4);
            this.testcases{6}.import{3} = struct('type', 'marker', 'channel', 5);
            this.testcases{6}.import{4} = struct('type', 'marker', 'channel', 6);
            this.testcases{6}.import{5} = struct('type', 'marker', 'channel', 7);
            this.testcases{6}.import{6} = struct('type', 'marker', 'channel', 8);
            
            % testcase 7 - channels with different sample rate
            % -------------------------------------------------------------
            this.testcases{7}.pth = 'ImportTestData/acq/PassiveAvoidance01019.acq';
            
            this.testcases{7}.import{1} = struct('type', 'scr', 'channel', 1);
            this.testcases{7}.import{2} = struct('type', 'hr', 'channel', 2);
            this.testcases{7}.import{3} = struct('type', 'marker', 'channel', 3);
            this.testcases{7}.import{4} = struct('type', 'marker', 'channel', 4);
            this.testcases{7}.import{5} = struct('type', 'marker', 'channel', 5);
            this.testcases{7}.import{6} = struct('type', 'marker', 'channel', 6);
           
        end
    end   
    
    methods (Test)
        function invalid_datafile(this)
            fn = 'ImportTestData/acq/Acq_SCR.acq';
            
            import{1} = struct('type', 'scr'   , 'channel', 1);
            import{2} = struct('type', 'marker', 'channel', 2);
            
            import = this.assign_chantype_number(import);
            
            this.verifyWarning(@()pspm_get_acq(fn, import), 'ID:channel_not_contained_in_file');
        end

        function get_acq_returns_same_data_as_acqknowledge_exported_mat(this)
            fpath_acq = 'ImportTestData/acq/impedance_acq.acq';
            import = {struct( ...
                'type', 'scr', ...
                'channel', 1, ...
                'transfer', 'none', ...
                'typeno', 1 ...
            )};
            [sts, import, sourceinfo] = pspm_get_acq(fpath_acq, import);
            this.verifyEqual(sts, 1);
            acq_data = import{1}.data;

            fpath_mat = 'ImportTestData/acq/impedance_mat.mat';
            orig_data = load(fpath_mat);
            orig_data = orig_data.data(:, 1);

            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            this.verifyThat(orig_data, IsEqualTo(acq_data, 'Within', RelativeTolerance(1e-10)));
        end
    end
    
end

