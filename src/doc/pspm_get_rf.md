# pspm_get_rf
## Description
pspm_get_rf estimates a response function from an event-related design (e.g. for further use in a GLM analysis), using a regularisation as third-order ODE and DCM machinery.

## Format
`theta = pspm_get_rf(fn, events, outfile, channel, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| fn | the file name of a PsPM data file. |
| events | specified in seconds as either (1) a vector of onsets, or (2) an SPM style onsets file with one event type, or (3) an epochs file (see pspm_dcm or pspm_get_epochs). |
| outfile | (optional) a file to write the response function to. |
| channel | (optional) data channel (default: look for first SCR channel). |
| options | [struct] to be passed on to pspm_dcm. |

