# pspm_dcm_inv
## Description
pspm_dcm_inv does trial-by-trial inversion of a DCM for skin conductance created by pspm_dcm. This includes estimating trial by trial estimates of sympathetic arousal as well as estimation of the impulse response function, if required.

Whether the IR is estimated from the data or not is determined by pspm_dcm and passed to the inversion routine in the options.

## Format
`[sts, dcm] = pspm_dcm_inv(model, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| model | See following fields. |
| model.scr | [cell_array] normalised and min-adjusted time series. |
| model.zfactor | Normalisation denominator from pspm_dcm. |
| model.sr | [numeric] sampling rate (must be the same across sessions). |
| model.events | [a cell of cell array] flexible and fixed events: model.events{1}{sn} - flexible; model.events{2}{sn} - fixed. |
| model.trlstart | [cell] trial start for each trial (created in pspm_dcm). |
| model.trlstop | [cell] trial end for each trial (created in pspm_dcm). |
| model.iti | [cell] ITI for each trial (created in pspm_dcm). |
| model.norm | [optional, default as 0] whether to normalise data. i. e. data are normalised during inversion but results transformed back into raw data units. |
| model.flexevents | [optional] flexible events to adjust amplitude priors. |
| model.fixevents | [optional] fixed events to adjust amplitude priors. |
| model.missing_data | [optional] missing epoch data, originally loaded as model.missing from pspm_dcm, but calculated into .missing_data (created in pspm_dcm and then transferred to pspm_dcm_inv. |
| model.constrained | [optional] constrained model for flexible responses which have have fixed dispersion (0.3 s SD) but flexible latency. || options | See following fields. |
| options.eSCR | [optional] contains the data to estimate RF from. |
| options.aSCR | [optional] contains the data to adjust the RF to. |
| options.meanSCR | [optional] data to adjust the response amplitude priors to. |
| options.crfupdate | [optional] update CRF priors to observed SCRF, or use pre-estimated priors (default). |
| options.getrf | [optional] only estimate RF, do not do trial-wise DCM. |
| options.rf | [optional] use pre-specified RF, provided in file, or as 4-element vector in log parameter space. |
| options.depth | [optional, numeric, default as 2] no of trials to invert at the same time. |
| options.sfpre | [optional, numeric, default as 2, unit: second] sf-free window before first event. |
| options.sfpost | [optional, numeric, default: 5, unit: second] sf-free window after last event. |
| options.sffreq | [optional, numeric, default: 0.5, unit: /second or Hz] maximum frequency of SF in ITIs. |
| options.sclpre | [optional, numeric, default: 2, unit: second] scl-change-free window before first event. |
| options.sclpost | [optional, numeric, default: 5, unit: second] scl-change-free window after last event. |
| options.aSCR_sigma_offset | [optional, numeric, default: 0.1, unit: second] minimum dispersion (standard deviation) for flexible responses. |
| options.dispwin | [optional, bool, default as 1] display progress window. |
| options.dispsmallwin | [optional, bool, default as 0] display intermediate windows. |
## Outputs
| Variable | Definition |
|:--|:--|
| dcm | Output units, all timeunits are in seconds. eSCR and aSCR amplitude are in SN units such that an eSCR SN pulse with 1 unit amplitude causes an eSCR with 1 mcS amplitude (unless model.norm = 1). |

## References
[1] Bach DR, Daunizeau J, Friston KJ, Dolan RJ (2010). Dynamic causal modelling of anticipatory skin conductance changes. Biological Psychology, 85(1), 163-70

[2] Staib, M., Castegnetti, G., & Bach, D. R. (2015). Optimising a model-based approach to inferring fear learning from skin conductance responses. Journal of Neuroscience Methods, 255, 131-138.


