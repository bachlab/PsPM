clc
clear
close all

%% Settings
% Please specify the path to the PsPM file here
FilePsPM = ['HeartBeat2-Josie-problem/tpspm_PP15.mat'];
% Please specify the path of python engine here
% PathPython = "/usr/local/Cellar/python@3.11/3.11.6_1/bin/python3";
% pyenv(Version=PathPython)
py.importlib.import_module('heartpy');
% Please add the path of PsPM source code here
addpath '/Users/teddy/GitHub/bachlab/PsPM/src'
ChannelAction = 'add';
ParametersSTFT = struct('TWindow',    16, ...
                        'TStep',      1, ...
                        'Tolerance',  0.5, ...
                        'HRCInit',    60);
TWindow = 16; % sliding window: 16s
TStep = 1; % moving step: 1s
Tolerance = 0.5;
HRCInit = 60; % init heart rate: 60bpm
% Main processing
ProcessingPsPM(FilePsPM, ChannelAction);
ProcessingHeartPy(FilePsPM, ChannelAction);
% HRCal = ProcessingSTFT(FilePsPM, ParametersSTFT);
%% Process with PsPM
function sts = ProcessingPsPM(FilePsPM, ChannelAction)
  OptionsPPG2HB = struct('diagnostics', 0, ...
                         'replace', 0, ...
                         'channel_action', ChannelAction);
  [sts, ~] = pspm_convert_ppg2hb( FilePsPM, 1, OptionsPPG2HB );
end
%% Process with heartPy
function sts = ProcessingHeartPy(FilePsPM, ChannelAction)
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
%% Process with STFT
function HRCal = ProcessingSTFT(FilePsPM, ParametersSTFT)
TWindow = ParametersSTFT.TWindow;
TStep = ParametersSTFT.TStep;
Tolerance = ParametersSTFT.Tolerance;
HRCInit = ParametersSTFT.HRCInit;
load(FilePsPM, 'data');
XPPG = data{1,1}.data;
FSampling = data{1,1}.header.sr;
HRCal = STFT(XPPG, FSampling, TWindow, TStep, Tolerance, HRCInit);
end
function HRCal = STFT(XPPG, FSampling, TWindow, TStep, Tolerance, HRCInit)
SizeWindow = TWindow*FSampling; % ws: sliding window size
SizeStep = TStep*FSampling; % ss: sliding step size
SizeStepCal = ceil((length(XPPG)/FSampling-TWindow)/TStep);
HRCal = zeros(SizeStepCal,1); % hrc: calculated heart rate
HRCal(1) = HRCInit;
[GPri, FPri, ~] = STFTCal(XPPG(1:1+SizeWindow), ...
  fix(length(XPPG(1:1+SizeWindow))/4), ...
  fix(length(XPPG(1:1+SizeWindow))/16), ...
  4096, ...
  FSampling);
FX = zeros(SizeStepCal,length(FPri));
GX = zeros(SizeStepCal,length(GPri));
for iStepCal = 1:1:SizeStepCal
  XPPGSeg = XPPG(round(1+SizeStep*(iStepCal-1)):round(1+SizeStep*(iStepCal-1)+SizeWindow));
  [GX(iStepCal,:),FX(iStepCal,:),~] = STFTCal(XPPGSeg, ...
    fix(length(XPPGSeg)/4), ...
    fix(length(XPPGSeg)/16), ...
    4096, ...
    FSampling);
  Freq = FX(iStepCal,:);
  FreqSpec = GX(iStepCal,:);
  [~, FlagEst] = findpeaks(FreqSpec);
  for iFlagEst = 1:1:length(FlagEst)
    FlagEst(iFlagEst) = FX(iStepCal,FlagEst(iFlagEst));
  end
  FlagEst(FlagEst>4) = [];
  CursorRef = HRCInit/60;
  if isempty(FlagEst)
    HRCal(iStepCal) = HRCal(iStepCal-1);
  end
  if iStepCal == 1
    Cursor = CursorRef;
    Trap = CursorRef;
    HRAssume = CursorRef;
    TargetPreStep = CursorRef;
  end
  if iStepCal~=1 && ~isempty(FlagEst)
    Trap = abs(FlagEst-HRCal(iStepCal-1)/60);
    Cursor = FlagEst(Trap==min(Trap));
    if length(Cursor) ~= 1
      temp_a = Cursor(1);
      temp_b = Cursor(2);
      if abs(temp_a-TargetPreStep)>abs(temp_b-TargetPreStep)
        Cursor(Cursor==temp_a) = [];
      else
        Cursor(Cursor==temp_b) = [];
      end
    end
    HRAssume = Cursor;
    if abs(Cursor-TargetPreStep) > Tolerance
      HRAssume = HRCal(iStepCal-1)/60;
    end
    HRCal(iStepCal) = HRAssume*60;
    TargetPreStep = HRAssume;
  end
end
end
function [STFT, F, T] = STFTCal(X, LWindow, H, NFFT, FS)
if size(X,2) > 1
  X = X';
end
LX = length(X);
Win = gausswin(LWindow);
NRow = ceil((1+NFFT)/2);
NCol = 1+fix((LX-LWindow)/H);
STFT = zeros(NRow, NCol);
Idx = 0;
Col = 1;
while Idx + LWindow <= LX
  % windowing
  XW = X(Idx+1:Idx+LWindow) .* Win;
  X = fft(XW, fix(NFFT));
  STFT(:,Col) = X(1:(NRow));
  Idx = Idx + H;
  Col = Col + 1;
end
T = (LWindow/2:H:LX-LWindow/2-1) / FS;
F = (0:NRow-1) * FS / NFFT;
STFT = abs(STFT(:,2));
end
function Y = CMAF(X,k)
A = zeros(fix(length(X)/k),k);
for i = 1:1:fix(length(X)/k)
  for j = 1:1:k
    A(i,j) = X(i*k-k+j);
  end
end
[Max,~] = max(A,[],2);
[Min,~] = min(A,[],2);
DSp = zeros(1,fix(length(X)/k));
for i = 1:length(DSp)
  DSp(i) = Max(i) - (Max(i)-Min(i))/2;
end
Y = zeros(1,length(DSp));
for i = 1:1:length(DSp)
  Asum = sum(A,2);
  Y(i) = Asum(i)/k;
end
end