# pspm_convert_hb2hp
## Description
pspm_convert_hb2hp transforms heart beat data into an interpolated heart rate signal and adds this as an additional channel to the data file

## Format
`[sts, channel_index] = pspm_convert_hb2hp(fn, sr, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| fn | data file name. |
| sr | new sample rate for heart period channel. |
| options | See following fields. |
| options.channel | [optional, numeric/string, default: 'hb', i.e. last heart beat channel in the file] Channel type or channel ID to be preprocessed. Channel can be specified by its index (numeric) in the file, or by channel type (string). If there are multiple channels with this type, only the last one will be processed. If you want to convert several heart beat channels in a PsPM file, call this function multiple times with the index of each channel. In this case, set the option 'channel_action' to 'add', to store each resulting 'hp' channel separately. |
| options.channel_action | ['add'/'replace', default as 'replace'] Defines whether heart rate signal should be added or the corresponding preprocessed channel should be replaced. |
| options.limit | [struct] Specifies upper and lower limit for heart periods. If the limit is exceeded, the values will be ignored/removed and interpolated. |
| options.upper | [numeric] Specifies the upper limit of the heart periods in seconds. Default is 2. |
| options.lower | [numeric] Specifies the lower limit of the heart periods in seconds. Default is 0.2. |
