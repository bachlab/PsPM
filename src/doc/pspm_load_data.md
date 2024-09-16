# pspm_load_data
## Description
pspm_load_data checks and returns the structure of PsPM 3-5.x and SCRalyze 2.x data files - SCRalyze 1.x is not supported

## Format
`[sts, infos, data, filestruct] = pspm_load_data(fn, channel)`

## Arguments
| Variable | Definition |
|:--|:--|
| fn | See following fields. |
| fn.infos | infos |
| fn.data | data || channel | See following fields. |
| channel.infos | (mandatory) |
| channel.data | (mandatory) |
| channel.options | (mandatory) |
## Outputs
| Variable | Definition |
|:--|:--|
| sts | [logical] 1 as default, -1 if check is unsuccessful. |
| infos | [struct] variable from data file. |
| data | cell array of channels as specified. |
| filestruct | See following fields. |
| filestruct.numofchan | number of channels. |
| filestruct.numofwavechan | number of wave channels. |
| filestruct.numofeventchan | number of event channels. |
| filestruct.posofmarker | position of the first marker channel 0 if no marker channel exists. |
| filestruct.posofchannels | number of the channels that were returned. |
