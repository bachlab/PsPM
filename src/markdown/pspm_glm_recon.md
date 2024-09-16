# pspm_glm_recon
## Description
pspm_glm_recon reconstructs the estimated responses and measures its peak.

Reconstructed responses are written into the field glm.resp, and reconstructed response peaks into the field glm.recon in original GLM file.

## Format
`glm = pspm_glm_recon(glmfile) or [sts, glm] = pspm_glm_recon(glmfile)`

## Arguments
| Variable | Definition |
|:--|:--|
| glmfile | the GLM file. |

## Outputs
| Variable | Definition |
|:--|:--|
| glm | calculated GLM struct. |

