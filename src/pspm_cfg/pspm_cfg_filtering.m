function filtering = pspm_cfg_filtering
% Updated 26-Feb-2024 by Teddy
% Initialise
global settings
if isempty(settings)
  pspm_init;
end
%% Global items
chan_nr                  = pspm_cfg_channel_selector('any');

%% Medianfilter
nr_time_pt               = cfg_entry;
nr_time_pt.name          = 'Number of Time Points';
nr_time_pt.tag           = 'nr_time_pt';
nr_time_pt.strtype       = 'i';
nr_time_pt.num           = [1 1];
nr_time_pt.help          = {'Number of time points over which the median is taken.'};
% Medianfilter
FilterMedian             = cfg_branch;
FilterMedian.name        = 'Median Filter';
FilterMedian.tag         = 'median';
FilterMedian.val         = {nr_time_pt};
FilterMedian.help        = {''};
%% Butterworth LP frequency
FreqLowPassNone          = cfg_const;
FreqLowPassNone.name     = 'none';
FreqLowPassNone.tag      = 'freqLP';
FreqLowPassNone.val      = {'none'};
FreqLowPassNone.help     = {'No sample rate defined.'};
FreqLowPassNum           = cfg_entry;
FreqLowPassNum.name      = 'number';
FreqLowPassNum.tag       = 'freqLP';
FreqLowPassNum.strtype   = 'r';
FreqLowPassNum.num       = [1 1];
FreqLowPassNum.help      = {'Define the low-pass filter frequency as a number.'};
FreqLowPass              = cfg_choice;
FreqLowPass.name         = 'Low-pass filter frequency';
FreqLowPass.tag          = 'freqLP';
FreqLowPass.values       = {FreqLowPassNone, FreqLowPassNum};
FreqLowPass.help         = {'Frequency of the low pass filter. It must be a number or "none" (default value).'};
%% Butterworth LP order
OrderLowPass             = cfg_entry;
OrderLowPass.name        = 'Low-pass filter order';
OrderLowPass.tag         = 'orderLP';
OrderLowPass.strtype     = 'r';
OrderLowPass.val         = {1};
OrderLowPass.num         = [1 1];
OrderLowPass.help        = {'Order of the low pass filter. It must be a non-zero integer. The default value is 1.'};
%% Butterworth HP frequency
FreqHighPassNone         = cfg_const;
FreqHighPassNone.name    = 'none';
FreqHighPassNone.tag     = 'freqHP';
FreqHighPassNone.val     = {'none'};
FreqHighPassNone.help    = {'No sample rate defined.'};
FreqHighPassNum          = cfg_entry;
FreqHighPassNum.name     = 'number';
FreqHighPassNum.tag      = 'freqHP';
FreqHighPassNum.strtype  = 'r';
FreqHighPassNum.num      = [1 1];
FreqHighPassNum.help     = {'Define the high-pass filter frequency as a number.'};
FreqHighPass             = cfg_choice;
FreqHighPass.name        = 'High-pass filter frequency';
FreqHighPass.tag         = 'freqHP';
FreqHighPass.values      = {FreqHighPassNone, FreqHighPassNum};
FreqHighPass.help        = {'Frequency of the high pass filter. It must be a number or "none" (default value).'};
%% Butterworth HP order
OrderHighPass            = cfg_entry;
OrderHighPass.name       = 'High-pass filter order';
OrderHighPass.tag        = 'orderHP';
OrderHighPass.strtype    = 'r';
OrderHighPass.val        = {1};
OrderHighPass.num        = [1 1];
OrderHighPass.help       = {'Order of the high pass filter. It must be a non-zero integer. The default value is 1.'};
%% Butterworth filter direction
FiltDirection            = cfg_menu;
FiltDirection.name       = 'Direction';
FiltDirection.tag        = 'direction';
FiltDirection.val        = {'uni'};
FiltDirection.labels     = {'Uni', 'Bi'};
FiltDirection.values     = {'uni', 'bi'};
FiltDirection.help       = {'Direction of the filter. Can be either "uni" or "bi".'};
%% Downsampling rate
DownSRNone               = cfg_const;
DownSRNone.name          = 'none';
DownSRNone.tag           = 'down';
DownSRNone.val           = {'none'};
DownSRNone.help          = {'No sample rate defined.'};
DownSRNum                = cfg_entry;
DownSRNum.name           = 'number';
DownSRNum.tag            = 'down';
DownSRNum.strtype        = 'r';
DownSRNum.num            = [1 1];
DownSRNum.help           = {'Define the post-downsampling sampling rate as a number.'};
DownSR                   = cfg_choice;
DownSR.name              = 'Sampling rate after downsampling';
DownSR.tag               = 'down';
DownSR.values            = {DownSRNone, DownSRNum};
DownSR.help              = {'Sample rate in Hz after downsampling. It must be a number or "none" (default value).'};
%% Butterworth filtering
FilterButter             = cfg_branch;
FilterButter.name        = 'Butterworth Filter';
FilterButter.tag         = 'butter';
FilterButter.val         = {OrderLowPass,FreqLowPass,OrderHighPass,FreqHighPass,FiltDirection,DownSR};
FilterButter.help        = {'Butterworth Filter.'};

%% Data file
datafile                 = cfg_files;
datafile.name            = 'Data File';
datafile.tag             = 'datafile';
datafile.num             = [1 1];
%datafile.filter         = '\.mat$';
datafile.help            = {settings.datafilehelp};

filtertype               = cfg_choice;
filtertype.name          = 'Filter Type';
filtertype.tag           = 'filtertype';
filtertype.values        = {FilterMedian,FilterButter};
filtertype.help          = {['Currently, median and butterworth ',...
                           'filters are implemented. A median filter is ' ...
                           'recommended for short spikes, generated ' ...
                           'for example in MRI scanners by gradient ' ...
                           'switching. A butterworth filter is applied ' ...
                           'in most models; check there to see whether ' ...
                           'an additional filtering is meaningful.']};
%% Overwrite file
overwrite                = cfg_menu;
overwrite.name           = 'Overwrite Existing File';
overwrite.tag            = 'overwrite';
overwrite.val            = {false};
overwrite.labels         = {'No', 'Yes'};
overwrite.values         = {false, true};
overwrite.help           = {'Overwrite if a file with the same name has existed?'};
%% Executable branch
filtering             = cfg_exbranch;
filtering.name        = 'Data filtering';
filtering.tag         = 'filtering';
filtering.val         = {datafile,chan_nr,filtertype,overwrite};
filtering.prog        = @pspm_cfg_run_filtering;
filtering.vout        = @pspm_cfg_vout_artefact;
filtering.help        = {['This module offers several basic filtering functions. ',...
                           'Currently, a median filter and a butterworth low pass ' ...
                           'filter are implemented. The median filter is useful to ' ...
                           'remove short "spikes" in the data, for example from gradient ' ...
                           'switching in MRI. The Butterworth filter can be used to get ' ...
                           'rid of high frequency noise that is not sufficiently ',...
                           'filtered away by the filters implemented on-the-fly during ',...
                           'first level modelling.']};

  function [sts, val] =  pspm_cfg_check_filtering_freq(val)
    sts = [];
    if val < 20
      sts = 'Cutoff Frequency hast to be at least 20 Hz';
    end
    if ~isempty(sts)
      uiwait(msgbox(sts));
    end
  end

  function vout = pspm_cfg_vout_artefact(job)
    vout = cfg_dep;
    vout.sname      = 'Output File';
    % this can be entered into any file selector
    vout.tgt_spec   = cfg_findspec({{'class','cfg_files'}});
    vout.src_output = substruct('()',{':'});
  end
end
