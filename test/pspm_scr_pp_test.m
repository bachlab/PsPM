classdef pspm_scr_pp_test < matlab.unittest.TestCase
% SCR_PP_TEST 
% unittest class for the pspm_pp function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus R�ttimann (University of Zurich)
    
    properties
    end
    
    methods (Test)
        function invalid_input(this)
            % test for invalid file
            this.verifyWarning(@()pspm_pp('butter', 'file'), 'ID:invalid_input');
            % for the following tests a valid file is required thus
            % generate some random data
            channels{1}.chantype = 'scr';
            channels{2}.chantype = 'hb';
            channels{3}.chantype = 'scr';
            
            fn = 'testfile549813.mat';
            pspm_testdata_gen(channels, 10, fn);
            % perform the other tests with invalid input data
            this.verifyWarning(@()pspm_scr_pp( fn, struct('sr', 10)), 'ID:invalid_input');
            % this.verifyWarning(@()pspm_pp('simple_qa', fn, struct('missing_epochs_filename', 1)), 'ID:invalid_input');
        end


%        function scr_pp_test(this)
%            %generate testdata
%            channels{1}.chantype = 'scr';
%            
%            fn = 'missing_epochs_test_generated_data.mat';
%            pspm_testdata_gen(channels, 10, fn);
%            
%            %filter one channel
%            missing_epoch_filename = 'missing_epochs_test_out';
%            qa = struct('missing_epochs_filename', missing_epoch_filename, ...
%                        'deflection_threshold', 0, ...
%                        'expand_epochs', 0 );
%            newfile = pspm_pp('simple_qa', fn, qa);
%            
%            [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
%                        
%            this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
%            this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
%            
%            delete(newfile);
%
%            out = load(missing_epoch_filename);
%            this.verifySize(out.epochs, [ 10, 2 ], 'the written epochs are not of the correct size')   
%            delete(string(missing_epoch_filename) + ".mat");
%
%
%            %no missing epochs filename option
%            newfile = pspm_pp('simple_qa', fn);
%            
%            [sts, infos, data, filestruct] = pspm_load_data(newfile, 'none');
%                        
%            this.verifyTrue(sts == 1, 'the returned file couldn''t be loaded');
%            this.verifyTrue(filestruct.numofchan == numel(channels), 'the returned file contains not as many channels as the inputfile');
%            
%            delete(newfile);
%            % test no file exists when not provided
%            this.verifyError(@()load('missing_epochs_test_out'), 'MATLAB:load:couldNotReadFile');
%
%            %delete testdata
%            delete(fn);
%        end

    end
    
end

