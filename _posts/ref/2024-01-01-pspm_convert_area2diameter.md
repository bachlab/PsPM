---
layout: post
title: pspm_convert_area2diameter
permalink: /ref/pspm_convert_area2diameter
---

[Back to index](/PsPM/ref/)

## Description

pspm_convert_area2diameter converts area values into diameter values.

All pupil size models in PsPM are defined for diameter values and require this conversion if the original data were recorded as area. In user mode, the function works on one or two channels in a PsPM file. In internal mode, it can also act on numerical vectors and returns a vector of converted values. 


## Format

`[sts, channel_index] = pspm_convert_area2diameter(fn, options)` or
`[sts, converted_data] = pspm_convert_area2diameter(area)`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | a numeric vector of milimeter values. |
| area | a numeric vector of area values (the unit is not important). |
| options | See following fields. |
| options.channel | [optional][numeric/string] [Default: 'both'] Channel ID to be preprocessed. To process both eyes, use 'both', which will work on 'pupil_r' and 'pupil_l'. To process a specific eye, use 'pupil_l' or 'pupil_r'. To process the combined left and right eye, use 'pupil_c'. The identifier 'pupil' will use the first existing option out of the following: (1) L-R-combined pupil; (2) non-lateralised pupil; (3) best eye pupil; (4) any pupil channel. ; If there are multiple channels of the specified type, only last one will be processed. You can also specify the number of a channel. |
| options.channel_action | ['add'/'replace', default as 'add'] Defines whether the new channel should be added or the previous outputs of this function should be replaced. |

[Back to index](/PsPM/ref/)
