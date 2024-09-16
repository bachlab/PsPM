# pspm_dcm
## Description
pspm_dcm sets up a non-linear SCR model, prepares and normalises the data, passes it over to the model inversion routine, and saves both the forward model and its inversion.

Non-linear SCR models are required if response timing is not known and has to be estimated from data. A typical example are anticipatory SCR in fear conditioning. These occur at some point between CS and US, but this time point is not known. 

Both flexible-latency (within a response window) and fixed-latency (evoked after a specified event) responses can be modelled.

For fixed responses, delay and dispersion are assumed to be constant (either pre-determined or estimated from the data), while for flexible responses, both are estimated for each individual trial.

Flexible responses can for example be anticipatory, decision-related, or evoked with unknown onset.

PsPM implements an iterative trial-by-trial algorithm. Different from GLM, response parameters are always estimated per trial, and the algorithm is not informed about the condition.

For each session, experimental timing is defined by providing a 1-column vector of event onsets in seconds for each fixed event, and a 2-column matrix for each flexible event. Each event must occur in each trial of a session, i.e. all these vectors and matrices must have the same number of rows. (For example, in fear conditioning where the US occurs only on a subset of trials, each trial includes an event "US onset" even if it does not occur, to avoid bias). A timing file should contain a variable 'events' which is a cell array; each cell should contain either a one-column vector or a 2-column matrix.

## Format
`[sts, dcm] = pspm_dcm(model, options)`

## Arguments
| Variable | Definition |
|:--|:--|
| model | See following fields. |
| model.modelfile | [string/cell array] The name of the model output file. |
| model.datafile | [string/cell array] A file name (single session) OR a cell array of file names. |
| model.timing | A file name/cell array of events (single session) OR a cell array of file names/cell arrays. When specifying file names, each file must be a *.mat file that contain a cell variable called 'events'. Each cell should contain either one column (fixed response) or two columns (flexible response). All matrices in the array need to have the same number of rows, i.e. the event structure should be the same for every trial. For trials that are not going to be analysed later, it is possible to include `dummy` events with negative onsets. All event timings must be specified in SECONDS. |
| model.missing | [optional] Allows to specify missing (e.g. artefact) epochs in the data file. See pspm_get_timing for epoch definition; specify a cell array for multiple input files. This must always be specified in SECONDS. Default: no missing values. |
| model.lasttrialcutoff | [optional] If there fewer data after the end of the last trial in a session than this cutoff value (in s), then estimated parameters from this trial will be assumed inestimable and set to NaN after the inversion. This value can be set as inf to always retain parameters from the last trial. Default: 7 s, corresponding to the time at which the canonical SCRF has decayed to around 80% of its peak value. |
| model.substhresh | [optional] Maximum duration (in seconds) of missing data periods allowed within a session (these data points will be ignored). For missing data periods longer than this threshold, the algorithm will split up the data into subsessions which are evaluated independently (excluding NaN values). Default: 2 s. |
| model.filter | [optional] Filter settings. Modality specific default. |
| model.channel | [optional] Channel number. Default: last SCR channel. |
| model.norm | [optional] Normalise data. i.e. Data are normalised during inversion but results transformed back into raw data units. Default: 0. |
| model.constrained | [optional] Constrained model for flexible responses which have fixed dispersion (0.3 s SD) but flexible latency. || options | See following fields. |
| options.crfupdate | [0/1] Re-estimate RF parameters from canonical SCRF, or use pre-estimated RF parameters. This can be used when f_SCR has been changed. |
| options.indrf | Estimate the response function from the data. This is only recommended for long inter-trial-intervals and should be used with caution. In reference 2, this option lead to worse quality of the trial-by-trial amplitude estimation (potenetially due to overfitting the data available to estimate the response function). Default: 0. |
| options.getrf | Only estimate response function, do not do trial-wise DCM. |
| options.rf | Call an external file to provide response function (for use when this is previously estimated by pspm_get_rf). |
| options.depth | Number of trials to invert at the same time. The iterative estimation will progress trial-by-trial and consider this number of trials into the future, until the last trial of a session. If this parameter is larger than the number of trials in a session, the entire sessin will be inverted at the same time. In reference 2, this parameter (set to 2 or 3) had no impact on the quality of the estimation. Unpublished data suggest that if a session with 24 trials and two events per trial is estimated in one go, then the quality of the estimation suffers (potentially because in the larger parameter landscape, it is more difficult to find the global minimum). Default: 2. |
| options.sfpre | SF-free interval before first event of a trial. Default: 2 s. |
| options.sfpost | SF-free interval after last event of a trial. Default: 5 s. |
| options.sffreq | Maximum frequency of SF in ITIs. Default: 0.5/s. |
| options.sclpre | SCR-change-free interval before first event of a trial. Default: 2 s. |
| options.sclpost | SCR-change-free interval after last event of a trial. Default: 5 s. |
| options.aSCR_sigma_offset | Minimum dispersion (standard deviation) for flexible responses, in seconds. Default: 0.1 s. |
| options.dispwin | [0/1] Display progress plot. Default: display. |
| options.dispsmallwin | [0/1] Display intermediate progress plots. Default: no display. |
| options.nosave | Don't save dcm structure (e.g. used by pspm_get_rf). |
| options.overwrite | [0/1] Define whether to overwrite existing output files or not. Default value: determined by pspm_overwrite. |
| options.trlnames | Cell array of names for individual trials. This is only for housekeeping (e.g. condition descriptions), not for model estimation. Default: no trial names. |
| options.eventnames | Cell array of names for individual events, in the order they are specified in the model.timing array - to be used for display and export only. |
## References
[1] Model development: Bach DR, Daunizeau J, Friston KJ, Dolan RJ (2010). Dynamic causal modelling of anticipatory skin conductance changes. Biological Psychology, 85(1), 163-70

[2] Model validation and improvement: Staib, M., Castegnetti, G., & Bach, D. R. (2015). Optimising a model-based approach to inferring fear learning from skin conductance responses. Journal of Neuroscience Methods, 255, 131-138.


