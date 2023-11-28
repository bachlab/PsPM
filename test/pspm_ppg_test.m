clc
clear
close all
FileTPsPM = '/Users/teddy/Library/CloudStorage/OneDrive-UniversityCollegeLondon/PsPM/PPG/Files Heartbeat/tpspm_PP11.mat';
load(FileTPsPM, 'data');
PPGSignal = data{1,1}.data;
PPGSignalSamplingFreq = data{1,1}.header.sr;
addpath '/Users/teddy/GitHub/bachlab/PsPM/src'

%% Process with PsPM
OptionsPPG2HB = struct('diagnostics', 1, ...
                       'replace', 0, ...
                       'channel_action', 'add');
[ sts, outinfo ] = pspm_convert_ppg2hb( FileTPsPM, 1, OptionsPPG2HB );

%% Process with heartPy
% pyenv(Version="/usr/local/Cellar/python@3.11/3.11.6_1/bin/python3") 
% (used by Mac)
% py.importlib.import_module('heartpy');
ppg_array = data{1,1}.data;
sample_rate = data{1,1}.header.sr;
filtered_ppg = py.heartpy.filter_signal(ppg_array, cutoff = [1,20], ...
    filtertype = 'bandpass', sample_rate = sample_rate, order = 3);
filtered_ppg = py.array.array('d',(filtered_ppg));
ppg_array = double(filtered_ppg);
tup = py.heartpy.process(ppg_array, sample_rate = sample_rate);
wd = tup{1};
m = tup{2};
py_peak_list =  py.array.array('d',(wd{'peaklist'}));
py_removed =  py.array.array('d',(wd{'removed_beats'}));
peak_list = double(py_peak_list) ;
rejected_peaks = double(py_removed);
figure(3);
plot(ppg_array);
hold on;
scatter(peak_list, ppg_array(peak_list), 'g', 'filled', 'DisplayName', 'Detected Peaks');
scatter(rejected_peaks, ppg_array(rejected_peaks), 'r', 'filled', 'DisplayName', 'Rejected Peaks');
title('PPG Data with Detected Peaks');
xlabel('Sample Index');
ylabel('PPG Value');
legend('PPG Data', 'Detected Peaks','Rejected Peaks');
grid on;
hold off;
fprintf('Saving data.');
msg = sprintf('Heart beat detection from PPG with cross correlation HB-timeseries added to data on %s', date);
newdata.data = peak_list(:) / sample_rate;
newdata.header.sr = sample_rate;
newdata.header.units = 'events';
newdata.header.chantype = 'hb';
write_options = struct();
write_options.msg = msg;
[nsts, nout] = pspm_write_channel(FileTPsPM, newdata, OptionsPPG2HB.channel_action, write_options);
if ~nsts
  return
end