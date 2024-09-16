# pspm_bf_spsrf_box
## Description
pspm_bf_spsrf_box constructs a boxcar function to produce the averaged scanpath speed over a 2-s time window in the end of SOA, which equals to scanpath length over a 2-s time window divided by 2/s

## Format
`[bs, x] = pspm_bf_spsrf_box(td, soa)` or
`[bs, x] = pspm_bf_spsrf_box([td, soa])`

## Arguments
| Variable | Definition |
|:--|:--|
| td | time resolution in second. |

## References
Xia Y, Melinscak F, Bach DR (2020) Saccadic Scanpath Length: An Index for Human Threat Conditioning Behavioral Research Methods 53, pages 1426–1439 (2021) doi: 10.3758/s13428-020-01490-5


