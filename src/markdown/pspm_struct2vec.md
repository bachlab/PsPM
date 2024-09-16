# pspm_struct2vec
## Description
pspm_struct2vec turns a numerical field in a multi-element structure array into a numerical vector. If in every element of the structure array, the field has one element, this returns the same output as [S(:).field]. If fields ar empty or have more than one element, the output vector will be made to have the same number of elements as S, and a warning will be thrown. 

## Format
`v = pspm_struct2vec(S, field, warningtype)`

## Arguments
| Variable | Definition |
|:--|:--|
| S | a structure array. |
| field | name of a numerical field. |
| warningtype | ['marker' or 'generic'] Type of warning to the displayed for the user. |

