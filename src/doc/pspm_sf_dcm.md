# pspm_sf_dcm
## Description
pspm_sf_dcm does dynamic causal modelling for SF of the skin conductance uses f_SF and g_Id the input data is assumed to be in mcS, and sampling rate in Hz

## Format
`[sts, dcm] = pspm_sf_dcm(model, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| model | See following fields. |
| model.scr | skin conductance epoch (maximum size depends on computing power, a sensible size is 60 s at 10 Hz). |
| model.sr | [numeric] [unit: Hz] sampling rate. |
| model.missing_data | [Optional] missing epoch data, originally loaded as model.missing from pspm_sf, but calculated into .missing_data (created in pspm_sf and then transferred to pspm_sf_dcm. || options | See following fields. |
| options.threshold | [numeric] [default: 0.1] [unit: mcS] threshold for SN detection (default 0.1 mcS). |
| options.theta | [vector] [default: read from pspm_sf_theta] a (1 x 5) vector of theta values for f_SF. |
| options.fresp | [numeric] [unit: Hz] [default: 0.5] frequency of responses to model. |
| options.dispwin | [logical] [default: 1] display progress window. |
| options.dispsmallwin | [logical] [default: 0] display intermediate windows. |
| options.missingthresh | [numeric] [default: 2] [unit: second] threshold value for controlling missing epochs, which is originally inherited from SF. |
## References
Bach DR, Daunizeau J, Kuelzow N, Friston KJ, & Dolan RJ (2011). Dynamic causal modelling of spontaneous fluctuations in skin conductance. Psychophysiology, 48, 252-57.


