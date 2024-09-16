# pspm_sf_mp
## Description
pspm_sf_mp does the inversion of a DCM for SF of the skin conductance, using a matching pursuit algorithm, and f_SF for the forward model the input data is assumed to be in mcS, and sampling rate in Hz.

## Format
`[sts, mp] = pspm_sf_mp(model, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| scr | skin conductance epoch (maximum size depends on computing power, a sensible size is 60 s at 10 Hz). |
| sr | sampling rate in Hz. |
| options | See following fields. |
| options.threshold | threshold for SN detection (default 0.1 mcS). |
| options.theta | a (1 x 5) vector of theta values for f_SF (default: read from pspm_sf_theta). |
| options.fresp | maximum frequency of modelled responses (default 0.5 Hz). |
| options.dispwin | display result window (default 1). |
| options.diagnostics | Add further diagnostics to the output. Is disabled if set to be false. If set to true this will add a further field 'D' to the output struct. Default is false. |
## References
[1] Bach DR, Staib M (2015). A matching pursuit algorithm for inferring tonic sympathetic arousal from spontaneous skin conductance fluctuations. Psychophysiology, 52, 1106-12.


