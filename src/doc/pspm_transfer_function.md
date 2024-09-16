# pspm_transfer_function
## Description
pspm_transfer_function converts input data into SCR in microsiemens assuming a linear transfer from total conductance to measured data

## Format
`scr = pspm_transfer_function(data, c, Rs, offset, recsys)` or
`scr = pspm_transfer_function(data, c, [Rs, offset, recsys])`

## Arguments
| Variable | Definition |
|:--|:--|
| data | the input data into SCR in microsiemens. |
| c | the transfer constant. Depending on the recording setting data = c * (measured total conductance in mcS) or data = c * (measured total resistance in MOhm) = c / (total conductance in mcS). |
| Rs | [optional] Series resistors (Rs) are often used as current limiters in MRI and will render the function non-linear. They can be taken into account (in Ohm) default: Rs=0. |
| offset | [optional, default as 0] Some systems have an offset (e.g. when using fiber optics in MRI, a minimum pulsrate), which can also be taken into account. Offset must be stated in data units. |
| recsys | [optional] There are two different recording settings which have an influence on the transfer function. Recsys defines in which setting the data (given in voltage) has been generated. Either the system is a 'conductance' based system (which is the default) or it is a 'resistance' based system. |

