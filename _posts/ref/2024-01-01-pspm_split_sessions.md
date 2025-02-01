---
layout: post
title: pspm_split_sessions
permalink: /ref/pspm_split_sessions
---
 
[Back to index](/PsPM/ref/)

## Description

pspm_split_sessions splits a continuous recording into experimental sessions/blocks. This can be useful to suppress noise or artefacts that occur in breaks (e.g. caused by participant movement or disconnection from the recording system) which can have an impact on pre-processing (e.g. filtering) and modelling. 

Splitting can be automated, based on regularly incoming markers (e.g. trial markers or volume/slice markers from an MRI scanner), or based on a vector of split points that is defined in terms of markers. In all cases, the first and the last markers will define the start of the first session and the end of the last session.

In addition, the function can split a (missing) epochs file associated with the original PsPM file to the same limits.

The individual session dat will be written to new files with a suffix '_sn' and the session number.


## Format

`[sts, newdatafile, newepochfile] = pspm_split_sessions(datafile, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| datafile | a file name. |
| options | See following fields. |
| options.marker_chan_num | [integer] number of the channel holding the markers. By default first 'marker' channel. |
| options.overwrite | [logical] (0 or 1) Define whether to overwrite existing output files or not. Default value: determined by pspm_overwrite. |
| options.max_sn | Define the maximum of sessions to look for. Default is 10 (defined by settings.split.max_sn). |
| options.min_break_ratio | Minimum for ratio [(session distance)/(maximum marker distance)] Default is 3 (defined by settings.split.min_break_ratio). |
| options.splitpoints | [Vector of integer] Explicitly specify start of each session in terms of markers, excluding the first session which is assumed to start with the first marker. |
| options.prefix | [numeric, unit:second, default: 0] Defines how many seconds of data before start trim point should also be included. Negative values required. First marker will be at t = - prefix for all sessions. Markers within the prefix period will be dropped. |
| options.suffix | [positive numeric, unit:second, default: mean marker distance in the file] Defines how many seconds of data after the end trim point should be included. Last marker will be at t = duration (of session) - suffix for all sessions. If set to 0, suffix will be set to the mean marker distance across the entire file. Markers within the suffix period will be dropped. |
| options.randomITI | [default:0] Tell the function to use all the markers to evaluate the mean distance between them. Usefull for random ITI since it reduces the variance. |
| options.verbose | [default:1] printing processing messages. |
| options.missing | Optional name of an epoch file, e.g. containing a missing epochs definition in s. This is then split accordingly. |


## Outputs

| Variable | Definition |
|:--|:--|
| newdatafile | cell array of filenames for the individual sessions. |
| newepochfile | cell array of missing epoch filenames for the individual sessions (empty if options.missing not specified). |


[Back to index](/PsPM/ref/)
