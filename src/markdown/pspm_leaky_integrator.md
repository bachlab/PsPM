# pspm_leaky_integrator
## Description
pspm_leaky_integrator applies a leaky integrator filter to the input data

## Arguments
| Variable | Definition |
|:--|:--|
| data | A numerical vector representing the input signal to be filtered. |
| tau | The time constant of the leaky integrator, representing the leak rate. The leak constant defines how quickly previous values "leak out" of the integrator (or decay). A higher tau value results in slower decay, meaning the integrator has a longer memory. |

