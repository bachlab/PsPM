classdef pspm_import_bids_test < matlab.unittest.TestCase
properties

test_data_path = 'ImportTestData/BIDs/Converted Data/'; % dataset level   
test_sub  =  'ImportTestData/BIDs/Converted Data/sub-CalinetWuerzburg03'; % subject level
test_ses  =  'ImportTestData/BIDs/Converted Data/sub-CalinetWuerzburg03/ses-01'; % session level
temp_dir_out  =  'ImportTestData/BIDs/tmp';
ref_path  =  'ImportTestData/BIDs/ref'; % *.mat already imported
exeption_path = 'ImportTestData/BIDs/Specialcases/';

move_list = { ...
% no behave marker (beh)
{'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/beh/sub-CalinetWuerzburg03_ses-01_task-FearAcquisition_events'};
% only eye1 data (physio) but with eyemarker
{'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/physio/sub-CalinetWuerzburg03_ses-01_task-FearAcquisition_recording-eye2_physio'};
% no eyes (phyfilePathsio) but with eyemarker
{'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/physio/sub-CalinetWuerzburg03_ses-01_task-FearAcquisition_recording-eye2_physio';
 'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/physio/sub-CalinetWuerzburg03_ses-01_task-FearAcquisition_recording-eye2_physio'};
% no eyes and no eyemarker 
{'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/physio/sub-CalinetWuerzburg03_ses-01_task-FearAcquisition_recording-eye2_physio';
 'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/physio/sub-CalinetWuerzburg03_ses-01_task-FearAcquisition_recording-eye2_physio';
 'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/physio/sub-CalinetWuerzburg03_ses-01_task-FearAcquisition_physioevents'};
% only eyesppermuations´
{ 'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/physio/sub-CalinetWuerzburg03_ses-01_recording-ecg_physio';
  'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/physio/sub-CalinetWuerzburg03_ses-01_recording-scr_physio';
  'ImportTestData/BIDs/Specialcases/sub-CalinetWuerzburg03/ses-01/physio/sub-CalinetWuerzburg03_ses-01_recording-ppg_physio'} 
 }
    % add more path permuations because´´
end



methods (TestClassSetup)
function setup_paths(testCase)
path = fileparts(pspm_path);

% Loop through the properties and prepend the test_data_path to each file path
for i = 1:length(testCase.move_list)
    for j = 1:length(testCase.move_list{i})
        testCase.move_list{i}{j} = fullfile(path, testCase.move_list{i}{j});
    end
end


testCase.test_data_path = fullfile(path, 'ImportTestData/BIDs/Converted Data/'); % dataset level   
testCase.test_sub    =  fullfile(path, 'ImportTestData/BIDs/Converted Data/sub-CalinetWuerzburg03'); % subject level
testCase.test_ses    =  fullfile(path, 'ImportTestData/BIDs/Converted Data/sub-CalinetWuerzburg03/ses-01'); % session level
testCase.temp_dir_out  =  fullfile(path, 'ImportTestData/BIDs/tmp');
testCase.ref_path    =  fullfile(path, 'ImportTestData/BIDs/ref'); % *.mat already imported
testCase.exeption_path = fullfile(path, 'ImportTestData/BIDs/Specialcases/');



% check for reference files? (add)

if ~exist(testCase.temp_dir_out)
    mkdir(testCase.temp_dir_out);
end
end
end

methods (TestClassTeardown)
    function cleanup(testCase)
            rmdir(testCase.temp_dir_out, 's');
    end
end



methods (Test)

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

%%
function test_session_with_missing(testCase)
    % Loop through the move_list and duplicate every entry
    for i = 1:length(testCase.move_list)
        for j = 1:length(testCase.move_list{i})
            files_to_move = {};

            original_file = testCase.move_list{i}{j}; % Get the original file path
            [original_path, fname,~] = fileparts(testCase.move_list{i}{j});
            % Create new entries for .json and .tsv


            json_file = fullfile(original_path, [fname,'.json']);
            tsv_file  = fullfile(original_path, [fname,'.tsv']);
            json_file_new = fullfile(original_path, [fname,'.json.tmp']);
            tsv_file_new  = fullfile(original_path, [fname,'.tsv.tmp']);            
            
            movefile(json_file,json_file_new)
            movefile(tsv_file, tsv_file_new)
            

            [sts, outfiles] = pspm_import_bids(testCase.test_ses, testCase.temp_dir_out);

            movefile(json_file_new,json_file)
            movefile(tsv_file_new,tsv_file)

            testCase.verifyEqual(sts,1)


        end
    end
end

function test_session_no_beh_import(testCase)
    % sub-CalinetWuerzburg03->ses-01
    
    [sts, outfiles] = pspm_import_bids(testCase.test_ses, testCase.temp_dir_out);
    
    % Verify success and single output file
    testCase.verifyEqual(sts, 1);
    testCase.verifyNumElements(outfiles, 1);
    
    expected_file = fullfile(testCase.temp_dir_out, 'pspm_sub-CalinetWuerzburg03_ses-01.mat');
    
    % Use exist() instead of verifyFileExists !!
    testCase.verifyEqual(outfiles{:},expected_file) % to check if it is at the right folder
    testCase.verifyTrue(exist(outfiles{:}, 'file') == 2, sprintf('File not found: %s', outfiles{:}));
    
    testCase.validate_pspm_file(outfiles{:});  
end


function test_invalid_dataset_path(testCase)

% Test non-existent dataset path
invalid_path = '/invalid/path';
testCase.verifyError(@() pspm_import_bids(invalid_path),'ID:invalid_input');
testCase.verifyError(@() pspm_import_bids(123),'ID:invalid_input');

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
    filepath_ref = fullfile(testCase.ref_path,[fn,'.mat']);
    [strf, ~, ~, filestruct_ref] = pspm_load_data(filepath_ref);
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
    [~, infos_ref, data_ref, ~] = pspm_load_data(filepath_ref,'wave');

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
    [~, infos_ref, data_ref, ~] = pspm_load_data(filepath_ref,'events');

    % Compare channel counts of the actual loaded channels
    testCase.verifyEqual(numel(data), numel(data_ref), 'Channel count mismatch'); % maybe assert?

    %  Compare channel duration
    duration = infos.duration;
    duration_ref = infos_ref.duration;
    testCase.verifyEqual(duration,duration_ref)

    for q = 1:numel(data)
        testCase.verifyEqual( length(data{q}.data) ,length(data_ref{q}.data) , duration_ref,'AbsTol', 0.001) ;% rigth tolerance?
    end
    % Ensure the function ends properly
    if nargout > 0
        varargout{1} = sts; % Return status if requested
    end
end    

    % % 4. Compare metadata
    % testCase.verifyEqual(loaded.infos.Participant.participant_id, ref.infos.Participant.participant_id, 'Participant ID mismatch');
    % testCase.verifyEqual(loaded.infos.task, ref.infos.task, 'Task name mismatch');

end
end

function moved_files = move_files(testCase, files_to_move, path)
    % Move specified files to the output directory and return their new paths
    moved_files = cell(size(files_to_move)); % Initialize cell array to store new file paths
    for i = 1:length(files_to_move)
        source_file = files_to_move{i}; % Use the full path provided
        [~, name, ext] = fileparts(source_file);
        destination_file = fullfile(path, [name, ext]); % Construct destination path
        
        if exist(source_file, 'file') == 2
            movefile(source_file, destination_file);
            moved_files{i} = destination_file; % Store the new file path
        else
            testCase.verifyFail(sprintf('File not found: %s', source_file));
        end
    end
end