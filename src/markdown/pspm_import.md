# pspm_import
## Description
pspm_import imports data from different formats and writes them to a file on the same path, with the original file name prepended with 'pspm_'. Please refer to the PsPM manual or the help of the individual 'pspm_get_[datatype] functions for data-type specific information.

## Format
`[sts, outfile] = pspm_import(datafile, datatype, import, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | [char] file name. |
| datatype | supported datatypes are defined in pspm_init (see manual). |
| import | See following fields. |
| import.type | (mandatory for all data types and each job) not all data types support all channel types. |
| import.sr | [mandatory for some data types and each channel] sampling rate for waveforms or time units in second for event channels, in Hz. |
| import.channel | [mandatory for some data types and each channel, positive integer; will search if set to 0 and data type allows] Specify where in the data file to find the channel; should be a positive integer (i. e. the n-th channel in the file); for some data types it is also possible to search for the channel by its name. Note: the channel number refers to the n-th recorded channel, not to its number or index in the recording software. For some data types, these can differ. |
| import.flank | [optional, string] The flank option specifies which of the rising edge (ascending), falling edge (descending), both edges or their mean (middle) of a marker impulse should be imported into the marker channel; The flank option is applicable for continuous channels only and accepts 'ascending', 'descending', or 'both'; The default value is 'both' that means to select the middle of the impulse; Some exceptions are Eyelink, ViewPoint and SensoMotoric Instruments data, for which the default are respectively ''both'', ''ascending'', ''ascending''; If the numbers of rising and falling edges differ, PsPM will throw an error. |
| import.transfer | [optional, string/struct] For SCR data only. Name of a .mat file containing values for the transfer function, OR a struct array containing the values OR 'none', when no conversion is required (c and optional Rs and offset; See pspm_transfer_function for more information). |
| import.eyelink_trackdist | The distance between eyetracker and the participants' eyes; If is a numeric value the data in a pupil channel obtained with an eyelink eyetracking system are converted from arbitrary units to distance unit; If value is 'none' the conversion is disabled; (only for Eyelink imports). |
| import.distance_unit | Unit in which the eyelink_trackdist is measured; If eyelink_trackdist contains a numeric value, the default value is 'mm' otherwise the distance unit is ''; Accepted values include 'mm', 'cm', 'm', and 'inches'. |
| import.denoise | for continuous marker channels or those recorded as digital level with two values (e.g. CED spike); retains markers of duration longer than the value given here (in seconds). |
| import.delimiter | for delimiter separated values, value used as delimiter for file read. || options | See following fields. |
| options.overwrite | overwrite existing files by default. [logical] (0 or 1) Define whether to overwrite existing output files or not. Default value: determined by pspm_overwrite. |
