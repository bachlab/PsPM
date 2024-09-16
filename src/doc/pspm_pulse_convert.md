# pspm_pulse_convert
## Description
pspm_pulse_convert converts pulsed data into a data waveform, assuming milliseconds as time unit and a resamplingrate in Hz given as input argument

## Format
`[sts, wavedata] = pspm_pulse_convert(pulsedata, resamplingrate, samplingrate)`

## Arguments
| Variable | Definition |
|:--|:--|
| pulsedata | timestamps in ms. |
| resamplingrate | for interpolation. |
| samplingrate | to be downsampled to. |

## Outputs
| Variable | Definition |
|:--|:--|
| sts | status of function processing. |
| wavedata | the waveform data that is converted from pulsed data. |

