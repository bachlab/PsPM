classdef pspm_import_bids_test < matlab.unittest.TestCase
properties
    test_data_path = 'ImportTestData/BIDs/Converted Data/'; % dataset level   
    test_sub  =  'ImportTestData/BIDs/Converted Data/sub-CalinetWuerzburg03'; % subject level
    test_ses  =  'ImportTestData/BIDs/Converted Data/sub-CalinetWuerzburg03/ses-01'; % session level
    temp_dir_out  =  'ImportTestData/BIDs/tmp';
    ref_path  =  'ImportTestData/BIDs/out/'; % *.mat already imported
     
end

%% Session-level test
function test_session_import(testCase)
    % sub-CalinetWuerzburg03->ses-01
    [sts, outfiles] = pspm_import_bids(testCase.test_ses, testCase.temp_dir_out);
    
    % Verify success and single output file
    testCase.verifyEqual(sts, 1);
    testCase.verifyNumElements(outfiles, 1);
    
    expected_file = fullfile(testCase.temp_dir_out, 'pspm_sub-CalinetWuerzburg03_ses-01.mat');
    
    % Use exist() instead of verifyFileExists
    testCase.verifyEqual(outfiles{:},expected_file) % to check if it is at the right folder
    testCase.verifyTrue(exist(outfiles{:}, 'file') == 2, sprintf('File not found: %s', outfiles{:}));
    testCase.validate_pspm_file(outfiles{:});
        

end


methods (TestClassSetup)
    function setup_paths(testCase)
        % check for reference files? (add)
        mkdir(testCase.temp_dir_out);
    end
end

methods (TestClassTeardown)
    function cleanup(testCase)
            rmdir(testCase.temp_dir_out, 's');
    end
end



methods (Test)
%% Dataset-level test
function test_dataset_import(testCase)
    [sts, outfiles] = pspm_import_bids(testCase.test_data_path, testCase.temp_dir_out);
    
    % Verify success and file count (5 files)
    testCase.verifyEqual(sts, 1, 'Import failed');
    testCase.verifyNumElements(outfiles, 5, 'Incorrect file count');
    
    % Validate each output file
    for i = 1:numel(outfiles)
        testCase.verifyTrue(exist(outfiles{i}, 'file') == 2, sprintf('File not found: %s', outfiles{i}));
        validate_pspm_file(testCase, outfiles{i});
    end
    
end

%% Subject-level test
function test_subject_import(testCase)
    % sub-CalinetWuerzburg03->ses-01,ses-02
    [sts, outfiles] = pspm_import_bids(testCase.test_sub, testCase.temp_dir_out);
    
    % Verify success and file count 2 files
    testCase.verifyEqual(sts, 1);
    testCase.verifyNumElements(outfiles, 2, 'Incorrect file count');
    
    % Validate session files
    for i = 1:2
        % expected_file = fullfile(testCase.temp_dir,   sprintf('pspm_sub-XX_ses-%02d.mat', i));
        % testCase.verifyEqual(outfiles{i},expected_file) 
        testCase.verifyTrue(exist(outfiles{i}, 'file') == 2, sprintf('File not found: %s', outfiles{i}));
        validate_pspm_file(testCase, outfiles{i});
    end

end



% function test_test_ss(testCase)
%     testCase.validate_pspm_file('/home/bernd/Banks/git/PsPM/ImportTestData/BIDs/out/pspm_sub-CalinetWuerzburg02_ses-01.mat');  
% end

% Path validation tests / problem by moveing the physio event json back
function test_invalid_dataset_path(testCase)

% Test non-existent dataset path
invalid_path = '/invalid/path';
testCase.verifyError(@() pspm_import_bids(invalid_path),'PsPM:InvalidPath');
testCase.verifyError(@() pspm_import_bids(123),'PsPM:InvalidInput');

% no marker channel
% test_ses  =  '/home/bernd/Banks/git/PsPM/ImportTestData/BIDs/CalinetWuerzburg BIDS Sample news/sub-CalinetWuerzburg03/ses-01' 
event_json  = 'physio/sub-CalinetWuerzburg03_ses-01_task-FearAcquisition_physioevents.json';
% event_tsv = 'physio/sub-CalinetWuerzburg03_ses-01_task-FearAcquisition_physioevents.tsv';

event_path = fullfile(testCase.test_ses,event_json);
event_path_tmp = fullfile(testCase.test_ses,'physio/tmp.json');

movefile(event_path,event_path_tmp)
testCase.verifyWarning(@() pspm_import_bids(testCase.test_ses),'PsPM:NoEvent');
movefile(event_path_tmp,event_path)

end


function test_invalid_save_path(testCase)
    % Test invalid save path type
    [sts, outfiles] = pspm_import_bids(testCase.test_ses, 123);
    testCase.verifyEqual(sts, 1);
    testCase.verifyNotEmpty(outfiles);
end



end
%% PSPM file validation helper
methods (Access = private)

function validate_pspm_file(testCase, filepath)


    % Verify pspm format & load imported file structure
    [sts, ~, ~, filestruct] = pspm_load_data(filepath);
    testCase.verifyEqual(sts,1,'Import failed')

    % Load reference file    
    [~, fn] = fileparts(filepath);
    reffilepath = fullfile(testCase.ref_path,[fn,'.mat']);
    [strf, ~, ~, filestruct_ref] = pspm_load_data(reffilepath);
    testCase.verifyEqual(strf,1,'Import reference file failed')

    
    % filestruct comparison(also values)
    f1 = fieldnames(filestruct);
    f2 = fieldnames(filestruct_ref);
    % different fields
    testCase.verifyEmpty( setdiff(f1,f2), 'Different fielstructs'); %%%
    testCase.verifyEmpty( setdiff(f2,f1), 'Different fielstructs'); %%%
    common     = intersect(f1, f2);
    for k = 1:numel(common)
        fld = common{k};
        testCase.verifyEqual(filestruct.(fld), filestruct_ref.(fld),'The filestructure is different');  
    end

    %% Compare key metrics
    % load wave data the data / length of the channels to compare
 
    [~, infos, data, ~] = pspm_load_data(filepath,'wave');
    [~, infos_ref, data_ref, ~] = pspm_load_data(reffilepath,'wave');

    % Compare channel counts of the actual loaded channels
    testCase.verifyEqual(numel(data), numel(data_ref), 'Channel count mismatch'); % maybe assert?

    %  Compare channel duration
    duration = infos.duration;
    duration_ref = infos_ref.duration;
    testCase.verifyEqual(duration,duration_ref)

    for q = 1:numel(data)
        testCase.verifyEqual( (length(data{q}.data) / data{q}.header.sr), duration_ref,'AbsTol', 0.001) ;% right tolerance?
    end
    
    %% marker

    [~, infos, data, ~] = pspm_load_data(filepath,'events');
    [~, infos_ref, data_ref, ~] = pspm_load_data(reffilepath,'events');

    % Compare channel counts of the actual loaded channels
    testCase.verifyEqual(numel(data), numel(data_ref), 'Channel count mismatch'); % maybe assert?

    %  Compare channel duration
    duration = infos.duration;
    duration_ref = infos_ref.duration;
    testCase.verifyEqual(duration,duration_ref)

    for q = 1:numel(data)
        testCase.verifyEqual( length(data{q}.data) ,length(data_ref{q}.data) , duration_ref,'AbsTol', 0.001) ;% rigth tolerance?
    end

    % % 4. Compare metadata
    % testCase.verifyEqual(loaded.infos.Participant.participant_id, ref.infos.Participant.participant_id, 'Participant ID mismatch');
    % testCase.verifyEqual(loaded.infos.task, ref.infos.task, 'Task name mismatch');

end
end
end