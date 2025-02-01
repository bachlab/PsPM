---
layout: post
title: pspm_expand_epochs
permalink: /ref/pspm_expand_epochs
---
 
[Back to index](/PsPM/ref/)

## Description

pspm_expand_epochs expands epochs in time, and merges overlapping epochs. 

This is useful in processing missing data epochs. The function can take a missing epochs file and creates a new file with the original name prepended with 'e', a matrix of missing epochs, or a PsPM data file with missing data in a given channel.


## Format

`[sts, output_file] = pspm_expand_epochs(epochs_fn, expansion, options)` or
`[sts, expanded_epochs] = pspm_expand_epochs(epochs, expansion, options) ` or
`[sts, channel_index] = pspm_expand_epochs(data_fn, channel, expansion , options)`


## Arguments

| Variable | Definition |
|:--|:--|
| epochs_fn | An epochs file as defined in pspm_get_timing. |
| epochs | A 2-column matrix with epochs onsets and offsets in seconds. |
| data_fn | A PsPM data file. |
| channel | Channel identifier accepted by pspm_load_channel. |
| expansion | A 2-element vector with positive numbers [pre, post]. |
| options | See following fields. |
| options.overwrite | Define if already existing files should be overwritten. Default ist 2. (Only used if input is epochs file.). |
| options.channel_action | Channel action, add / replace existing data data (default: add). |


[Back to index](/PsPM/ref/)
