# pspm_jobman
## Description
Main interface for PsPM Batch System Initialise jobs configuration and set MATLAB path accordingly.

## Format
→ Standard
`pspm_jobman('initcfg')` or
`pspm_jobman('run',job)` or
`output_list = pspm_jobman('run',job)`
→ Run specified job
`job_id = pspm_jobman` or
`job_id = pspm_jobman('interactive')` or
`job_id = pspm_jobman('interactive',job)` or
`job_id = pspm_jobman('interactive',job,node)` or
`job_id = pspm_jobman('interactive','',node)`

## Arguments
| Variable | Definition |
|:--|:--|
| job | filename of a job (.m or .mat), or cell array of filenames, or 'jobs'/'matlabbatch' variable, or cell array of 'jobs'/'matlabbatch' variables. |
| output_list | cell array containing the output arguments from each module in the job. The format and contents of these outputs is defined in the configuration of each module (.prog and .vout callbacks). |
| node | indicate which part of the configuration is to be used. |
| job_id | can be used to manipulate this job in cfg_util. Note that changes to the job in cfg_util will not show up in cfg_ui unless 'Update View' is called. |

