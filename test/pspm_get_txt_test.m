classdef pspm_get_txt_test < pspm_get_superclass
% SCR_GET_TXT_TEST 
% unittest class for the pspm_get_txt function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus R�ttimann (University of Zurich)
       
    properties
        testcases;
        fhandle = @pspm_get_txt;
    end
    
    methods
        function define_testcases(this)
            %testcase 1
            %--------------------------------------------------------------
            this.testcases{1}.pth = 'testdatafile79887.txt';
            
            this.testcases{1}.import{1} = struct('type', 'scr'   , 'channel', 1, 'sr', 100);
            this.testcases{1}.import{2} = struct('type', 'scr'   , 'channel', 2, 'sr', 100);
            this.testcases{1}.import{3} = struct('type', 'hr'    , 'channel', 5, 'sr', 100);
            this.testcases{1}.import{4} = struct('type', 'resp'  , 'channel', 6, 'sr', 100);
            this.testcases{1}.import{5} = struct('type', 'scr'   , 'channel', 7, 'sr', 100);
            
            %generate testdata
            data = rand(900, 8);
            save(this.testcases{1}.pth, 'data', '-ascii');
            
            %testcase 2 (with header)
            %--------------------------------------------------------------
            this.testcases{2}.pth = 'testdatafile49821.txt';
            
            this.testcases{2}.import{1} = struct('type', 'scr'   , 'channel', 0, 'sr', 100);
            this.testcases{2}.import{2} = struct('type', 'ecg'   , 'channel', 0, 'sr', 100);
            this.testcases{2}.import{3} = struct('type', 'hr'    , 'channel', 0, 'sr', 100);
            this.testcases{2}.import{4} = struct('type', 'resp'  , 'channel', 0, 'sr', 100);
            
            %generate testdata
            header = {'scr' 'ecg' 'heart' 'resp'};
            data = rand(900, 4);
            
            fid = fopen(this.testcases{2}.pth, 'w');
            fprintf(fid,'scr\t\t\tecg\t\t\trate\t\tresp\n');
            for k=1:size(data,1)
                fprintf(fid,'%f\t%f\t%f\t%f\n', data(k,1), data(k,2), data(k,3), data(k,4));
            end
            fclose(fid);

            %testcase 3 (csv with header)
            %--------------------------------------------------------------
            this.testcases{3}.pth = 'testdatafile132435.csv';
            
            this.testcases{3}.import{1} = struct('type', 'scr'   , 'channel', 0, 'sr', 100, 'delimiter', ',');
            this.testcases{3}.import{2} = struct('type', 'ecg'   , 'channel', 0, 'sr', 100, 'delimiter', ',');
            this.testcases{3}.import{3} = struct('type', 'hr'    , 'channel', 0, 'sr', 100, 'delimiter', ',');
            this.testcases{3}.import{4} = struct('type', 'resp'  , 'channel', 0, 'sr', 100, 'delimiter', ',');
            
            %generate testdata
            header = {'scr' 'ecg' 'heart' 'resp'};
            data = rand(900, 4);
            
            fid = fopen(this.testcases{3}.pth, 'w');
            fprintf(fid,'scr,ecg,rate,resp\n');
            for k=1:size(data,1)
                fprintf(fid,'%f,%f,%f,%f\n', data(k,1), data(k,2), data(k,3), data(k,4));
            end
            fclose(fid);

            %testcase 4 (delimiter separated value with custom delimiter (|))
            %--------------------------------------------------------------
            this.testcases{4}.pth = 'testdatafile132435.psv';
            
            this.testcases{4}.import{1} = struct('type', 'scr'   , 'channel', 0, 'sr', 100, 'delimiter', '|');
            this.testcases{4}.import{2} = struct('type', 'ecg'   , 'channel', 0, 'sr', 100, 'delimiter', '|');
            this.testcases{4}.import{3} = struct('type', 'hr'    , 'channel', 0, 'sr', 100, 'delimiter', '|');
            this.testcases{4}.import{4} = struct('type', 'resp'  , 'channel', 0, 'sr', 100, 'delimiter', '|');

            %generate testdata
            header = {'scr' 'ecg' 'heart' 'resp'};
            data = rand(900, 4);
            
            fid = fopen(this.testcases{4}.pth, 'w');
            fprintf(fid,'scr|ecg|rate|resp\n');
            for k=1:size(data,1)
                fprintf(fid,'%f|%f|%f|%f\n', data(k,1), data(k,2), data(k,3), data(k,4));
            end
            fclose(fid);
            
        end
    end
    
    methods (TestClassTeardown)
        function del_testdata_files(this)
            delete(this.testcases{1}.pth);
            delete(this.testcases{2}.pth);
            
            this.testcases = [];
        end
    end
    
    methods (Test)
        function invalid_datafile(this)
            fn = 'testdatafile79887.txt';
            
            import{1} = struct('type', 'scr'   , 'channel', 1);
            import{2} = struct('type', 'scr'   , 'channel', 2);
            import{3} = struct('type', 'scr'   , 'channel',15);
            
            import = this.assign_chantype_number(import);
            
            this.verifyWarning(@()pspm_get_txt(fn, import), 'ID:channel_not_contained_in_file');
        end
        
    end
    
end

