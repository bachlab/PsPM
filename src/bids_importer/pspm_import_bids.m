function sts = pspm_import_bids(dataset_path, save_path)
% function sts = pspm_import_bids(dataset_path, save_path)
% PSPM_IMPORT_BIDS
%   reads a BIDS formatted pupil dataset(experimental readings for a set of participants) from a given data path
%   stores data in pspm formatted structures

% dataset_path = './input/data/';
% save_path = './output/';

addpath(fullfile('lib'));

% load_dataset
dataset = load_bids_dataset(dataset_path);

% save dataset
save_dataset_as_pspm(dataset, save_path);

% Load the BIDS dataset for physio data
physio_dataset = load_bids_physio_dataset(dataset_path);

% Save the physio dataset in PSPM format
save_dataset_as_pspm_physio(physio_dataset, save_path);

sts = 1;
end