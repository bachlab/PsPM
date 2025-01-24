---
layout: post
title: pspm_get_markerinfo
permalink: /ref/pspm_get_markerinfo
---


[Back to index](/PsPM/ref/)

## Description

pspm_get_markerinfo extracts markerinfo from PsPM files that contain such information (e.g. BrainVision or NeuroScan), and returns this or writes it into a matlab file with a struct variable 'markerinfo', with one element per unique marker name/value.


## Format

`[sts, markerinfo] = pspm_get_markerinfo(filename, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| filename | [char] name of PsPM file if empty, you will be prompted for one. |
| options | See following fields. |
| options.marker_chan_num | [int] marker channel number. if undefined or 0, first marker channel is used. |
| options.filename | [char] name of a file to write the markerinfo to; default value: empty, meaning no file will be written. |
| options.overwrite | [logical] (0 or 1) Define whether to overwrite existing output files or not. Default value: determined by pspm_overwrite. |

[Back to index](/PsPM/ref/)
