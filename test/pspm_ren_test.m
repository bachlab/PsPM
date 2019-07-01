classdef pspm_ren_test < matlab.unittest.TestCase
% SCR_REN_TEST 
% unittest class for the pspm_ren function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus Rüttimann (University of Zurich)
    
    properties
    end
    
    methods (Test)
        function invalid_input(this)
            this.verifyWarning(@()pspm_ren('fn'), 'ID:invalid_input');
            this.verifyWarning(@()pspm_ren({'fn1', 'fn2'}, {'rfn1', 'rfn2', 'rfn3'}), 'ID:invalid_input');
        end
        
        function char_valid_input(this)
            fn = 'testdatafile78965424.mat';            
            rfn = 'rtestdatafile78965424.mat';
            
            channels.chantype = 'scr';
            pspm_testdata_gen(channels, 10, fn);
            
            newfilename = pspm_ren(fn, rfn);
            
            [sts, infos, data] = pspm_load_data(newfilename);
            
            this.verifyTrue(strcmpi(newfilename,rfn), '''newfilename'' has not the expected value');
            this.verifyTrue(sts == 1, 'sts is negativ');
            this.verifyTrue(isfield(infos, 'rendate'), 'the field infos.rendate is missing');
            this.verifyTrue(isfield(infos, 'newname'), 'the field infos.newname is missing');
            this.verifyTrue(~exist(fn, 'file'), 'the original file has not been deleted');
            
            delete(rfn);
        end
        
        function cell_valid_input(this)        
            fn{1} = 'testdatafile78965423.mat';
            fn{2} = 'testdatafile78654354.mat';         
            rfn{1} = 'rtestdatafile78965423.mat';
            rfn{2} = 'rtestdatafile78654354.mat';
            
            channels.chantype = 'scr';
            pspm_testdata_gen(channels, 10, fn{1});
            pspm_testdata_gen(channels, 10, fn{2});
            
            newfilename = pspm_ren(fn, rfn);
            
            for k=1:numel(fn)
                [sts, infos, data] = pspm_load_data(newfilename{k});

            this.verifyTrue(strcmpi(newfilename{k},rfn{k}), '''newfilename'' has not the expected value');
            this.verifyTrue(sts == 1, 'sts is negativ');
            this.verifyTrue(isfield(infos, 'rendate'), 'the field infos.rendate is missing');
            this.verifyTrue(isfield(infos, 'newname'), 'the field infos.newname is missing');
            this.verifyTrue(~exist(fn{k}, 'file'), 'the original file has not been deleted');
            
            delete(rfn{k});
            end
        end
    end
    
end

