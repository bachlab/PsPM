function artefact_rm = pspm_cfg_artefact_rm
% Updated 26-Feb-2024 by Teddy
% Initialise
global settings
if isempty(settings)
  pspm_init;
end
%% Global items
chan_nr                  = cfg_entry;
chan_nr.name             = 'Channel Number';
chan_nr.tag              = 'chan_nr';
chan_nr.strtype          = 'i';
chan_nr.num              = [1 Inf];
chan_nr.help             = {''};
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
FreqLowPass.name         = 'High-pass filter frequency';
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
%% simple SCR quality correction
% ScrMin: SCR minimum value
ScrMin                   = cfg_entry;
ScrMin.name              = 'Minimum value';
ScrMin.tag               = 'min';
ScrMin.strtype           = 'r';
ScrMin.num               = [1 1];
ScrMin.val               = {0.05};
ScrMin.help              = {'Minimum SCR value in microsiemens.'};
% ScrMax: SCR maximum value
ScrMax                   = cfg_entry;
ScrMax.name              = 'Maximum value';
ScrMax.tag               = 'max';
ScrMax.strtype           = 'r';
ScrMax.num               = [1 1];
ScrMax.val               = {60};
ScrMax.help              = {'Maximum SCR value in microsiemens.'};
% ScrSlope:
ScrSlope                 = cfg_entry;
ScrSlope.name            = 'Maximum slope';
ScrSlope.tag             = 'slope';
ScrSlope.strtype         = 'r';
ScrSlope.num             = [1 1];
ScrSlope.val             = {10};
ScrSlope.help            = {'Maximum SCR slope in microsiemens per second.'};

ScrMissEpoNoFN           = cfg_const;
ScrMissEpoNoFN.name      = 'Do not write to file';
ScrMissEpoNoFN.tag       = 'no_missing_epochs';
ScrMissEpoNoFN.val       = {0};
ScrMissEpoNoFN.help      = {'Do not store artefacts epochs to file'};

ScrMissEpoFN             = cfg_entry;
ScrMissEpoFN.name        = 'File name';
ScrMissEpoFN.tag         = 'filename';
ScrMissEpoFN.strtype     = 's';
ScrMissEpoFN.num         = [ 1 Inf ];
ScrMissEpoFN.help        = {['Specify the name of the file where ',...
                           'to store artefact epochs. Provide only ',...
                           'the name and not the extension, the ',...
                           'file will be stored as a .mat file.']};

ScrMissEpoFP             = cfg_files;
ScrMissEpoFP.name        = 'Output Directory';
ScrMissEpoFP.tag         = 'outdir';
ScrMissEpoFP.filter      = 'dir';
ScrMissEpoFP.num         = [1 1];
ScrMissEpoFP.help        = {'Specify the directory where the .mat file ',...
                           'with artefact epochs will be written.'};

ScrMissEpoF              = cfg_exbranch;
ScrMissEpoF.name         = 'Write to filename';
ScrMissEpoF.tag          = 'write_to_file';
ScrMissEpoF.val          = {ScrMissEpoFN, ScrMissEpoFP};
ScrMissEpoF.help         = {['If you choose to store the artefact ',...
                           'epochs please specify a filename as well ',...
                           'as an output directory. When giving the ',...
                           'filename do not specify any extension, the ',...
                           'artefact epochs will be stored as .mat file.']};
ScrMissEpo               = cfg_choice;
ScrMissEpo.name          = 'Missing epochs file';
ScrMissEpo.tag           = 'missing_epochs';
ScrMissEpo.val           = {ScrMissEpoNoFN};
ScrMissEpo.values        = {ScrMissEpoNoFN, ScrMissEpoF};
ScrMissEpo.help          = {'Specify if you want to store the artefact ',...
                           'epochs in a separate file of not.', ...
                           'Default: artefact epochs are not stored.'};

ScrDeflectionThr         = cfg_entry;
ScrDeflectionThr.name    = 'Deflection threshold';
ScrDeflectionThr.tag     = 'deflection_threshold';
ScrDeflectionThr.strtype = 'r';
ScrDeflectionThr.num     = [1 1];
ScrDeflectionThr.val     = {0.1};
ScrDeflectionThr.help    = {['Define an threshold in original data ',...
                           'units for a slope to pass to be considered ',...
                           'in the filter. ', ...
                           'This is useful, for example, with ',...
                           'oscillatory wave data. ', ...
                            'The slope may be steep due to a jump ',...
                           'between voltages but we likely do not want ', ...
                            'to consider this to be filtered. ', ...
                           'A value of 0.1 would filter oscillatory ', ...
                           'behaviour with threshold less than 0.1v ', ...
                           'but not greater.' ],...
                           'Default: 0.1', ...
                           };

ScrDataIslandThr         = cfg_entry;
ScrDataIslandThr.name    = 'Data island threshold';
ScrDataIslandThr.tag     = 'data_island_threshold';
ScrDataIslandThr.strtype = 'r';
ScrDataIslandThr.num     = [1 1];
ScrDataIslandThr.val     = {0};
ScrDataIslandThr.help    = {['A float in seconds to determine the ' ...
                           'maximum length of unfiltered data ' ...
                           'between epochs.', ...
                           ' If an island exists for less than the ' ...
                           'threshold it will also be filtered'], ...
                           'Default: 0 s - will take no effect on ' ...
                           'filter', ...
                           };

ScrExpandEpo             = cfg_entry;
ScrExpandEpo.name        = 'Expand epochs';
ScrExpandEpo.tag         = 'expand_epochs';
ScrExpandEpo.strtype     = 'r';
ScrExpandEpo.num         = [1 1];
ScrExpandEpo.val         = {0.5};
ScrExpandEpo.help        = {'A float in seconds to determine ',...
                           'by how much data on the flanks of ',...
                           'artefact epochs will be removed.', ...
                           'Default: 0.5 s.'};
scr_pp                   = cfg_branch;
scr_pp.name              = 'Preprocessing SCR';
scr_pp.tag               = 'scr_pp';
scr_pp.val               = {ScrMin, ...
                           ScrMax, ...
                           ScrSlope, ...
                           ScrMissEpo, ...
                           ScrDeflectionThr, ...
                           ScrDataIslandThr, ...
                           ScrExpandEpo};
scr_pp.help              = {['Preprocessing SCR. See I. R. Kleckner ',...
                           'et al.,"Simple, Transparent, and Flexible '...
                           'Automated Quality Assessment Procedures ',...
                           'for Ambulatory Electrodermal Activity ',...
                           'Data," in IEEE Transactions on Biomedical ', ...
                           'Engineering, vol. 65, no. 7, pp. 1460-1467,',...
                           'July 2018.']};
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
artefact_rm             = cfg_exbranch;
artefact_rm.name        = 'Artefact Removal';
artefact_rm.tag         = 'artefact_rm';
artefact_rm.val         = {datafile,chan_nr,filtertype,overwrite};
artefact_rm.prog        = @pspm_cfg_run_artefact_rm;
artefact_rm.vout        = @pspm_cfg_vout_artefact;
artefact_rm.help        = {['This module offers a few basic artefact removal functions. ',...
                           'Currently, a median filter and a butterworth low pass ' ...
                           'filter are implemented. The median filter is useful to ' ...
                           'remove short "spikes" in the data, for example from gradient ' ...
                           'switching in MRI. The Butterworth filter can be used to get ' ...
                           'rid of high frequency noise that is not sufficiently ',...
                           'filtered away by the filters implemented on-the-fly during ',...
                           'first level modelling.']};

  function [sts, val] =  pspm_cfg_check_artefact_rm_freq(val)
    sts = [];
    if val < 20
      sts = 'Cutoff Frequency hast to be at least 20Hz';
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
