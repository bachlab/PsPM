---
layout: post
title: pspm_convert_au2unit
permalink: /ref/pspm_convert_au2unit
---
 
[Back to index](/PsPM/ref/)

## Description

pspm_convert_au2unit converts arbitrary unit values to unit values. It works on a PsPM file and is able to replace a channel or add the data as a new channel.

Important features: Given arbitrary unit values are converted using a recording distance D given in 'unit', a reference distance Dref given in 'reference_unit', a multiplicator A given in 'reference_unit'.

Before applying the conversion, the function takes the square root of the input data if the recording method is area. This is performed to always return linear units.

Using the given variables, the following calculations are performed: 0. Take square root of data if recording is 'area'.

1. Let from unit to reference_unit converted recording distance be Dconv.

2. x ← A*(Dconv/Dref)*x 3. Convert x from ref_unit to unit.


## Format

`[sts, channel_index] = pspm_convert_au2unit(fn, unit, distance, record_method,` or
`multiplicator, reference_distance, reference_unit, options)` or
`[sts, converted_data] = pspm_convert_au2unit(data, unit, distance, record_method,` or
`multiplicator, reference_distance, reference_unit, options)`


## Arguments

| Variable | Definition |
|:--|:--|
| fn | Filename which contains the channels to be converted. |
| data | A one-dimensional vector which contains the data to be converted. |
| unit | To which unit the data should be converted. possible values are mm, cm, dm, m, in, inches. |
| distance | Distance between camera and eyes in units as specified in the parameter unit. |
| record_method | Either 'area' or 'diameter', tells the function what the format of the recorded data is. |
| multiplicator | The multiplicator in the linear conversion. |
| reference_distance | Distance at which the multiplicator value was obtained, as specified in the parameter unit. The values will be proportionally translated to this distance before applying the conversion function. |
| reference_unit | Reference unit with which the multiplicator and reference_distance values were obtained. Possible values are mm, cm, dm, m, in, inches. |
| options | See following fields. |
| options.channel | [optional][numeric/string] [Default: 'both'] Channel ID to be preprocessed. To process both eyes, use 'both', which will work on 'pupil_r' and 'pupil_l'. To process a specific eye, use 'pupil_l' or 'pupil_r'. To process the combined left and right eye, use 'pupil_c'. The identifier 'pupil' will use the first existing option out of the following: (1) L-R-combined pupil; (2) non-lateralised pupil; (3) best eye pupil; (4) any pupil channel. If there are multiple channels of the specified type, only last one will be processed. You can also specify the number of a channel. |
| options.channel_action | ['add'/'replace', default as 'add'] Defines whether the new channel should be added or the previous outputs of this function should be replaced. |


[Back to index](/PsPM/ref/)
