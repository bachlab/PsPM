function pspm_text(path)
% ● Description
%   pspm_text handles the text for GUI display.
% ● History
%   Introduced in PsPM 6.0
%   Written and maintained in 2022 by Teddy
helptext_import_acq = '';
helptext_import_acqmat = '';
helptext_import_bioread = 'Loads mat files which have been converted using the bioread tool acq2mat. Bioread can be installed using pip (installed by python) or can be downloaded and installed manually from here https://github.com/njvack/bioread. It requires python and the python libraries numpy and scipy.';
helptext_import_csv = 'Read using comma as a delimiter.';
helptext_import_dsv = 'Reads a file using a custom delimiter, for example a delimiter or a comma (,) would read the same as a csv';
helptext_import_labchartmat = 'Supports the import of any original Labchart (.adicht) file. Since it uses an external library, this import is restricted to Windows systems only and does not work on any other operating system.';
helptext_import_matlab = 'Each input file must contain a variable called data that is either a cell array of column vectors, or a data points channels matrix. The import of event markers is supported. Marker channels are assumed to be continuous if the input data is a matrix or if the input data is a cell and the given samplerate is larger than 1 Hz. A sample rate has to be specified for any type of data.';
helptext_import_spike = '';
helptext_import_txt = 'Text files can only contain numbers (i.e. no header lines with channel names) and one data column per channel. Make sure you use the decimal point (i.e. not decimal comma as used in some non-English speaking countries). At the moment, no import of event markers is possible.';
helptext_import_labchartmat_ext = 'Export data to matlab format (plugin for the LabChart software, available from https://www.adinstruments.com).';
helptext_import_labchartmat_in = '';
helptext_import_vario = '';
helptext_import_biograph = 'Export data to text format, both "Export Channel Data" and "Export Interval Data" are supported; a header is required';
helptext_import_physlog = 'The physlog ascii file contains 6 channels with physiological measurements (Channel id 1-6): ECG1, ECG2, ECG3, ECG4, Pulse oxymeter, Respiration. Depending on your scanner settings, there are 10 trigger channels of which channel 6 marks time t of the last slice recording. After importing, a time window from t minus (#volumes )*(repetition time) seconds until t should be used for trimming or splitting of sessions to constrain data in the imported file to the EPI recording window and easier matching with experimental events from a separate source. Available trigger channels are (Channel id 1-10): Trigger ECG, Trigger PPG, Trigger Respiration, Measurement (?slice onset?), Start of scan sequence, End of scan sequence, Trigger external, Calibration, Manual start, Reference ECG Trigger.';
helptext_import_viewpoint = 'See pspm_get_viewpoint documentation';
helptext_import_smi = 'See pspm_get_smi documentation';
helptext_import_eyelink = 'Eyelink output files (with extension *.edf) must first be converted to ASCII format (extension *.asc). This is done with the utility edf2asc.exe (normally included in the Eyelink software in <Path to Program Files>\SR Research\EyeLink\EDF_Access_API\). Otherwise there is a Data viewer, available at http://www.sr-research.com/dv.html (registration needed), which installs a utility called ''Visual EDF2ASC''. This also allows the conversion and does not require a license. The composition of channels depends on the acquisition settings. Available channels are Pupil L, Pupil R, x L, y L, x R, y R, Blink L, Blink R, Saccade L, Saccade R. The channels will be imported according to a known data structure, therefore channel ids passed to the import function or set in the Batch will be ignored. In the PsPM file channels, which were not available in the data file, will be padded with NaN values. Additionally periods of blinks and saccades will be set to NaN during the import.';
helptext_import_edf = '';
helptext_import_biosemi = '';
helptext_import_windaq_n = 'Windaq import written by the PsPM team. It is platform independent, thus has no requirements for ActiveX Plugins, Windows or 32bit Matlab. Imports the original acquisition files files. Up to now the import has been tested with files of the following type: Unpacked, no Hi-Res data, no Multiplexer files. A warning will be produced if the imported data-type fits one of the yet untested cases. If this is the case try to use the import provided by the manufacturer (see above).';
helptext_import_cnt = '';
helptext_import_observer = '';
helptext_import_biotrace = '';
helptext_import_brainvision = '';
helptext_import_windaq = 'Requires an ActiveX Plugin provided by the manufacturer and contained in the subfolder Import/wdq for your convenience. This plugin only runs under 32 bit Matlab on Windows.';

warntext_subfolder = 'All subdirectories of the main directory are loaded into the MATLAB search path. This is not necessary and may even cause trouble during runtime. It is recommended to only add the path of the main directory to the search path.';
warntext_matlab_old = 'You are running PsPM on a Matlab version (%s) under which it has not been tested.\nSPM 8 functions will be automatically added to you path but may not run. 1st level GLM may not run.\nIf you encounter any other error, please contact the developers.';
warntext_matlabbatch = 'Matlabbatch from SPM and its config folder are currently on your MATLAB search path.\n\nDo you want to remove these folders temporarily from your MATLAB search path in order to avoid potential issues with matlabbatch from PsPM?';
warntext_sigproc_toolbox = 'Signal processing toolbox not installed. Some filters might not be implemented.';
warntext_spm_remove = 'The software SPM is currently on your MATLAB search path.\n\nDo you want to remove the folders belonging to SPM from your MATLAB search path in order to avoid potential issues with PsPM?';
warntext_spm_quit = 'Start of PsPM had to be quit, because of interference with the software SPM, which was on your MATLAB search path. To run PsPM be sure to remove the folders of SPM from your MATLAB search path.';

save(fullfile(path,'pspm_text.mat'))
return
