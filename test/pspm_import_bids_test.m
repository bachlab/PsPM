classdef pspm_import_bids_test < matlab.unittest.TestCase
properties
    test_data_path = '/home/bernd/Banks/git/PsPM/ImportTestData/BIDs/CalinetWuerzburg BIDS Sample news/'; % dataset level   
    test_sub  =  '/home/bernd/Banks/git/PsPM/ImportTestData/BIDs/CalinetWuerzburg BIDS Sample news/sub-CalinetWuerzburg03'; % subject level
    test_ses  =  '/home/bernd/Banks/git/PsPM/ImportTestData/BIDs/CalinetWuerzburg BIDS Sample news/sub-CalinetWuerzburg03/ses-01' % session level
    temp_dir  =  '/home/bernd/Banks/git/PsPM/ImportTestData/BIDs/out/tmp';
end

methods (TestClassSetup)
    function setup_paths(testCase)
        
        mkdir(testCase.temp_dir);
    end
end

methods (TestClassTeardown)
    function cleanup(testCase)
            rmdir(testCase.temp_dir, 's');
    end
end



methods (Test)
%% Dataset-level test
function test_dataset_import(testCase)
    [sts, outfiles] = pspm_import_bids(testCase.test_data_path, testCase.temp_dir);
    
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
    [sts, outfiles] = pspm_import_bids(testCase.test_sub, testCase.temp_dir);
    
    % Verify success and file count 2 files
    testCase.verifyEqual(sts, 1);
    testCase.verifyNumElements(outfiles, 2, 'Incorrect file count');
    
    % Validate session files
    for i = 1:2
        % expected_file = fullfile(testCase.temp_dir,   sprintf('pspm_sub-XX_ses-%02d_cogent.mat', i));
        % testCase.verifyEqual(outfiles{i},expected_file) 
        testCase.verifyTrue(exist(outfiles{i}, 'file') == 2, sprintf('File not found: %s', outfiles{i}));
        validate_pspm_file(testCase, outfiles{i});
    end

end

%% Session-level test
function test_session_import(testCase)
    % sub-CalinetWuerzburg03->ses-01
    [sts, outfiles] = pspm_import_bids(testCase.test_ses, testCase.temp_dir);
    
    % Verify success and single output file
    testCase.verifyEqual(sts, 1);
    testCase.verifyNumElements(outfiles, 1);
    
    expected_file = fullfile(testCase.temp_dir, 'pspm_sub-CalinetWuerzburg03_ses-01_cogent.mat');
    
    % Use exist() instead of verifyFileExists
    testCase.verifyEqual(outfiles{:},expected_file) % to check if it is at the right folder
    testCase.verifyTrue(exist(outfiles{:}, 'file') == 2, sprintf('File not found: %s', outfiles{:}));
    testCase.validate_pspm_file(outfiles{:});
        

end

%% Path validation tests
% function test_invalid_path(testCase)
%     % Test non-existent dataset path
%     testCase.verifyError(...
%         @() pspm_import_bids('/invalid/path', testCase.temp_dir), ...
%         'pspm_import_bids:dataset_path has to be a folder');
% end

% function test_missing_savepath(testCase)
%         % Test automatic output directory creation
%         [~, outfiles] = pspm_import_bids(testCase.test_ses);
%         testCase.verifyFileExists(outfiles{1});
%     end
% end


end
%% PSPM file validation helper
methods (Access = private)

function validate_pspm_file(testCase, filepath)
%     % Load current test output
%     loaded = load(filepath);
% 
%     % Verify basic structure
%     testCase.verifyTrue(isfield(loaded, 'infos'), 'Missing infos');
%     testCase.verifyTrue(isfield(loaded, 'data'), 'Missing data');
%     testCase.verifyTrue(isfield(loaded.infos, 'Participant'), 'Missing Participant');
%     testCase.verifyTrue(isfield(loaded.infos, 'DatasetDescription'), 'Missing DatasetDescription');
% 
%     % Check channel consistency
%     testCase.verifyGreaterThan(numel(loaded.data), 1, 'Insufficient channels');
%     durations = cellfun(@(c) c.header.duration, loaded.data);
%     testCase.verifyEqual(range(durations), 0, 'Channel duration mismatch');
%     testCase.verifyEqual(loaded.infos.duration, durations(1), ...
%         'Metadata/header duration mismatch');
% 
%     %% Compare against reference files
%     % Extract filename and session ID
%     [~, current_filename] = fileparts(filepath);
%     ses_id = regexp(current_filename, 'ses-(\d+)', 'tokens', 'once');
% 
%     % Get reference directory (one level up from test_data_path)
%     ref_dir = fileparts(testCase.test_data_path);
%     ref_files = dir(fullfile(ref_dir, 'out', 'pspm_*.mat'));
% 
%     % Find matching reference file
%     ref_match = '';
%     for i = 1:numel(ref_files)
%         if contains(ref_files(i).name, ses_id) && ...
%            contains(ref_files(i).name, regexp(current_filename, 'sub-\w+', 'match', 'once'))
%             ref_match = fullfile(ref_dir, 'out', ref_files(i).name);
%             break;
%         end
%     end
% 
%     if isempty(ref_match)
%         warning('Reference file not found for %s', current_filename);
%         return;
%     end
% 
%     % Load reference file
%     ref = load(ref_match);
% 
%     %% Compare key metrics
%     % 1. Compare channel counts
%     testCase.verifyEqual(numel(loaded.data), numel(ref.data), ...
%         'Channel count mismatch');
% 
%     % 2. Compare channel durations
%     loaded_durations = cellfun(@(c) c.header.duration, loaded.data);
%     ref_durations = cellfun(@(c) c.header.duration, ref.data);
%     testCase.verifyEqual(loaded_durations, ref_durations, ...
%         'Channel duration values mismatch', 'AbsTol', 0.001);
% 
%     % 3. Compare marker channel data
%     for c = 1:numel(loaded.data)
%         if isfield(loaded.data{c}, 'markerinfo')
%             testCase.verifyEqual(loaded.data{c}.data, ref.data{c}.data, ...
%                 'Marker data mismatch', 'AbsTol', 0.001);
%             break;
%         end
%     end
% 
%     % 4. Compare metadata
%     testCase.verifyEqual(loaded.infos.Participant.participant_id, ...
%         ref.infos.Participant.participant_id, 'Participant ID mismatch');
%     testCase.verifyEqual(loaded.infos.task, ref.infos.task, 'Task name mismatch');
end
end
end