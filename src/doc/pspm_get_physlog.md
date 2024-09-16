# pspm_get_physlog
## Description
pspm_get_physlog imports Philips Scanphyslog data, generated from the monitoring equipment of Philips MRI scanners. The physlog ascii file contains 6 channels with physiological measurements (Channel id 1-6): ECG1, ECG2, ECG3, ECG4, Pulse oxymeter, Respiration. Depending on the scanner settings, there are 10 marker channels of which channel 6 marks time t of the last slice recording. In order to align the data to start and end of EPI sequences, a time window from t minus (#volumes )* (repetition time) seconds until t should be used for trimming. 

Available marker channels are (Channel id 1-10): ECG marker, PPG marker, respiration marker, Measurement (?slice onset?), Start of scan sequence, End of scan sequence, Trigger external, Calibration, Manual start, Reference ECG Trigger.

## Format
`[sts, import, sourceinfo] = pspm_get_physlog(datafile, import);`

## Arguments
| Variable | Definition |
|:--|:--|
| datafile | datafile to be imported. |
| import | import settings. |

## Outputs
| Variable | Definition |
|:--|:--|
| sts | status. |
| import | the updated import structure. |
| sourceinfo | the source information structure. |

