clc
clear
close all

%% Settings
% Please specify the path to the PsPM file here
FilePsPM = ["/Users/teddy/Library/CloudStorage/",...
            "OneDrive-UniversityCollegeLondon/PsPM/",...
            "PPG/Files Heartbeat/tpspm_PP11.mat"];
% Please specify the path of python engine here
PathPython = "/usr/local/Cellar/python@3.11/3.11.6_1/bin/python3"
pyenv(Version=PathPython)
py.importlib.import_module('heartpy');
% Please add the path of PsPM source code here
addpath '/Users/teddy/GitHub/bachlab/PsPM/src'
ChannelAction = 'add';
% Main processing
ProcessingPsPM(FilePsPM);
ProcessingHeartPy(FilePsPM);

%% Process with PsPM
function sts = ProcessingPsPM(FilePsPM, ChannelAction)
  OptionsPPG2HB = struct('diagnostics', 1, ...
                         'replace', 0, ...
                         'channel_action', ChannelAction);
  [sts, outinfo] = pspm_convert_ppg2hb( FilePsPM, 1, OptionsPPG2HB );
end
%% Process with heartPy
function sts = ProcessingHeartPy(FilePsPM)
  load(FilePsPM, 'data');
  ppg_array = data{1,1}.data;
  sample_rate = data{1,1}.header.sr;
  filtered_ppg = py.heartpy.filter_signal(ppg_array, ...
                                          cutoff = [1,20], ...
                                          filtertype = 'bandpass', ...
                                          sample_rate = sample_rate, ...
                                          order = 3);
  filtered_ppg = py.array.array('d',(filtered_ppg));
  ppg_array = double(filtered_ppg);
  tup = py.heartpy.process(ppg_array, sample_rate = sample_rate);
  wd = tup{1};
  m = tup{2};
  py_peak_list =  py.array.array('d',(wd{'peaklist'}));
  py_removed =  py.array.array('d',(wd{'removed_beats'}));
  peak_list = double(py_peak_list) ;
  rejected_peaks = double(py_removed);
  msg = sprintf(['Heart beat detection from PPG with cross correlation ',...
                 'HB-timeseries added to data on %s'],...
                 date);
  newdata.data = peak_list(:) / sample_rate;
  newdata.header.sr = sample_rate;
  newdata.header.units = 'events';
  newdata.header.chantype = 'hb';
  write_options = struct();
  write_options.msg = msg;
  [sts, nout] = pspm_write_channel(FilePsPM, ...
                                   newdata, ...
                                   ChannelAction, ...
                                   write_options);
  if ~sts
    return
  end
end