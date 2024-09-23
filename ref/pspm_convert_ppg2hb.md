# pspm_convert_ppg2hb
[Back to index](/PsPM/ref/)

## Description

pspm_convert_ppg2hb converts a pulse oxymeter channel to heartbeats.

First a template is generated from non-ambiguous heartbeats. The ppg signal is then cross-correlated with the template and maxima are identified as heartbeats.


## Format

`[sts, channel_index] = pspm_convert_ppg2hb( fn, options )`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | file name with path. |
| options | See following fields. |
| options.method | 'classic' (default) or 'heartpy'. |
| options.channel | [optional, numeric/string, default: 'ppg', i.e. last PPG channel in the file] Channel type or channel ID to be preprocessed. Channel can be specified by its index (numeric) in the file, or by channel type (string). If there are multiple channels with this type, only the last one will be processed. If you want to process several PPG channels in a PsPM file, call this function multiple times with the index of each channel. In this case, set the option 'channel_action' to 'add', to store each resulting 'hb' channel separately. |
| options.diagnostics | [true/FALSE] displays some debugging information. |
| options.channel_action | ['add'/'replace', 'replace'] Defines whether the interpolated data should be added or the corresponding channel should be replaced. |
| options.missing | allows to specify missing (e. g. artefact) epochs in the data file. See pspm_get_timing for epoch definition. This must always be specified in SECONDS. These epochs will be set to 0 for the detection. Default: no missing values. |
| options.lsm | [integer] for method 'classic' large spikes mode compensates for large spikes while generating template by removing the [integer] largest percentile of spikes from consideration. |
| options.python_path | [char] for method 'heartpy' The path where python can be found. Mandatory if python environment is not yet set up. |

[Back to index](/PsPM/ref/)
