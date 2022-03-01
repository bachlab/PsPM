classdef pspm_get_events_test < matlab.unittest.TestCase
% PSPM_GET_EVENTS_TEST 
% unittest class for the pspm_get_events function
%__________________________________________________________________________
% SCRalyze TestEnvironment
% (C) 2013 Linus R�ttimann (University of Zurich)
  
    methods
        function check = checkFlankChange(this, positions, data)
            positions(:,2) = positions(:,1) - 1;         
            % horizontal diff: check wheter pos and (pos-1) have
            % different values;
            check = (sum(abs(sign(diff(data(positions),1,2)))) == length(positions));
        end
    end

    methods (Test)
        function check_warnings(this)
            import.sr = 1;
            import.data = ones(100, 1);
            
            this.verifyWarning(@()pspm_get_events(import), 'ID:nonexistent_field');
            
            import.marker = 'foo';
            this.verifyWarning(@()pspm_get_events(import), 'ID:invalid_field_content');            
        end
        
        function timestamps(this)
            import.marker = 'timestamps';
            import.sr = 10^-3;
            import.data = 1:3:10000;
            
            [sts, rimport] = pspm_get_events(import);
            
            this.verifyEqual(sts, 1);
            this.verifyTrue(length(rimport.data) == length(import.data));
        end
        
        function continuous(this)
            import.marker = 'continuous';
            import.sr = 10^3;
            t = import.sr^-1:import.sr^-1:10;
            d = [1 2.5 6 8];
            import.data = pulstran(t,d,'rectpuls', 0.1);
            
            [sts, rimport] = pspm_get_events(import);
            
            this.verifyEqual(sts, 1);
            this.verifyTrue(length(rimport.data) == length(rimport.markerinfo.value));
            this.verifyTrue(length(rimport.data) == length(d));
            
            % save returned data for the next test
            no_b_line.data = rimport.data;
            no_b_line.markerinfo = rimport.markerinfo;
            % test with baseline offset 
            import.data = import.data + 50;
            [sts, rimport] = pspm_get_events(import);
            this.verifyEqual(sts, 1);
            this.verifyTrue(length(rimport.data) == length(rimport.markerinfo.value));
            this.verifyTrue(length(rimport.data) == length(d));

            % check if baseline has been removed
            this.verifyTrue(isequal(rimport.data, no_b_line.data));
            this.verifyTrue(isequal(rimport.markerinfo, no_b_line.markerinfo));
            % remove baseline for the following tests
            import.data = import.data - 50;
            
            %test with inverted signal
            import.data = -1 * import.data;
            [sts, rimport] = pspm_get_events(import);
            this.verifyEqual(sts, 1);
            this.verifyTrue(length(rimport.data) == length(rimport.markerinfo.value));
            %if we invert the signal, number of markers denoted by high signals is one more!
            this.verifyTrue(length(rimport.data) == length(d) + 1);
            import.data = -1 * import.data;
            
            import.flank = 'ascending';
            [sts, rimport] = pspm_get_events(import);
            this.verifyEqual(sts, 1);
            this.verifyTrue(length(rimport.data) == length(rimport.markerinfo.value));
            this.verifyTrue(length(rimport.data) == length(d));
            this.verifyTrue(this.checkFlankChange(round(rimport.data.*rimport.sr), import.data));
                       
            import.flank = 'descending';
            [sts, rimport] = pspm_get_events(import);
            this.verifyEqual(sts, 1);
            this.verifyTrue(length(rimport.data) == length(rimport.markerinfo.value));
            this.verifyTrue(length(rimport.data) == length(d));
            this.verifyTrue(this.checkFlankChange(round(rimport.data.*rimport.sr), import.data));
            
            %test with angular flanks
            import.data = pulstran(t,d,'tripuls', 0.1);
            import.data(import.data >= 0.5) = 0.5;
            [sts, rimport] = pspm_get_events(import);
            this.verifyEqual(sts, 1);
            this.verifyTrue(length(rimport.data) == length(rimport.markerinfo.value));
            this.verifyTrue(length(rimport.data) == length(d));
                      
            % test with data of a user
            % the data contains more than just two states of markers
            % which former versions of that function didn't support
            pth = strcat(fileparts(mfilename('fullpath')), ...
                '/../ImportTestData/pspm_get_events/import_acq_multimarker.mat');
            load(pth);
            % its an acq import
            [sts, rimport] = pspm_get_events(import_acq);
            this.verifyEqual(sts, 1);
            % it should have 36 markers i know it
            this.verifyTrue(length(rimport.data) == length(rimport.markerinfo.value));
            this.verifyTrue(length(rimport.data) == 36);
            
            % set marker info and use data from angular flanks test
            import.markerinfo.value = (1);
            import.markerinfo.name = ('do not overwrite please');
            [sts, rimport] = pspm_get_events(import);
            this.verifyTrue(isequal(rimport.markerinfo, import.markerinfo));
            
            %test with marker channel having only two marker
            clear import;
            import.marker = 'continuous';
            import.sr = 10^3;
            import.data = zeros(10000,1);
            idx_mrk__one = randi([1 4999],1,5);
            idx_mrk__two = randi([5000 10000],1,5);
            import.data(idx_mrk__one) = 1;
            import.data(idx_mrk__two) = 2;
            d = [idx_mrk__one,idx_mrk__two];
            d = sort(d./import.sr);
            rounded_d = round(d*100)/100;
            
            [sts, rimport] = pspm_get_events(import);
            this.verifyEqual(sts, 1);
            this.verifyTrue(length(rimport.data) == length(rimport.markerinfo.value));
            this.verifyTrue(length(rimport.data) == length(d));
            disp('rimport.data')
            disp(rimport.data)
            disp('d')
            disp(d)
            rounded_rimport_data = round(rimport.data*100)/100;
            this.verifyTrue(all(rounded_rimport_data == transpose(rounded_d)));
            disp('rounded_rimport_data')
            disp(rounded_rimport_data)
            disp('rounded_d')
            disp(rounded_d)
            this.verifyTrue(all(ismember(rimport.markerinfo.value,[1,2])) & ...
                all(ismember([1,2],rimport.markerinfo.value)));

        end
    end
    
end

