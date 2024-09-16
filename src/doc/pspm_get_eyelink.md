# pspm_get_eyelink
## Description
pspm_get_eyelink imports asc-exported SR Research Eyelink 1000 files.

Original eyelink output files (with extension *.edf) must first be converted to ASCII format (extension *.asc). This is done with the utility edf2asc.exe (normally included in the Eyelink software in <Path to Program Files>\SR Research\EyeLink\EDF_Access_API\). Otherwise (registration needed), which installs a utility called 'Visual EDF2ASC'. This also supports the conversion and does not require a license. 

The sequence of channels depends on the acquisition settings, please check in the ASCII file using text editor. Available channels are Pupil L, Pupil R, x L, y L, x R, y R, Blink L, Blink R, Saccade L, Saccade R. The channels will be imported according to a known data structure, therefore channel ids passed to the import function will be ignored. In the PsPM file, channels that were not available in the data file, will be filled with NaN values. Additionally, periods of blinks and saccades will be set to NaN during the import.

## Format
`[sts, import, sourceinfo] = pspm_get_eyelink(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| import | See following fields. |
| import.sr | sampling rate. |
| import.data | except for custom channels, the field .channel will be ignored. The id will be determined according to the channel type. |
| import.eyelink_trackdist | [optional] A numeric value representing the distance between camera and recorded eye. Disabled if 0 or negative. If it is a positive numeric value, causes the conversion from arbitrary units to distance unit according to the set distance. |
| import.distance_unit | [optional] The unit to which the data should be converted and in which eyelink_trackdist is given. |
