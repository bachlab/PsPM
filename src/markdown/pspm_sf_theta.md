# pspm_sf_theta
## Description
pspm_sf_theta returns parameter values for skin conductance response function f_SF.

## Format
`[theta, sr] = pspm_sf_theta`

## Outputs
| Variable | Definition |
|:--|:--|
| theta | a vector as [theta1, theta2, theta3, theta4, theta5]. |
| theta1 | ODE parameter. |
| theta2 | ODE parameter. |
| theta3 | ODE parameter. |
| theta4 | delay parameter, should be the same as for aSCR model as there is no explicit knowledge of SN bursts so it cannot be empirically determined this was corrected on 12.05.2014. |
| theta5 | scaling parameter in log space, was slightly adapted on 12.05.2014 such that an input with unit amplitude elicits a response with exactly unit amplitude, see pspm_f_amplitude_check.m. |
| sr | sampling rate. |

