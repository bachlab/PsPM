# pspm_pupil_correct
## Description
pspm_pupil_correct performs pupil foreshortening error (PFE) correction for arbitrary eye tracker measurements according to equations (3) and (4) in [1].

## Format
`[sts, pupil_corrected] = pspm_pupil_correct(pupil, gaze_x_mm, gaze_y_mm, geometry_setup)`

## Arguments
| Variable | Definition |
|:--|:--|
| pupil | Numeric array containing pupil diameter. (Unit: any unit). |
| gaze_x_mm | Numeric array containing gaze x positions. (Unit: mm). |
| gaze_y_mm | Numeric array containing gaze y positions. (Unit: mm). |
| geometry_setup | See following fields. |
| geometry_setup.C_x | Horizontal displacement of the center of camera lens, i.e. how much to the left or to the right the camera looks for a sitting person whose pupil is at O. (Unit: mm). |
| geometry_setup.C_y | Vertical displacement of the center of camera lens, i.e. how much to the top or to the bottom the camera looks for a sitting person whose pupil is at O. (Unit: mm). |
| geometry_setup.C_z | The distance between pupil center and camera center if they have same x and y coordinates. (Unit: mm). |
| geometry_setup.S_x | Horizontal displacement of the top left corner of screen i.e. how much to the left or to the right the top left corner of screen looks for a sitting person whose pupil is at O. (Unit: mm). |
| geometry_setup.S_y | Vertical displacement of the top left corner of screen i.e. how much to the top or to the bottom the top left corner of screen looks for a sitting person whose pupil is at O. (Unit: mm). |
| geometry_setup.S_z | The distance between pupil center and top left corner of screen if they have same x and y coordinates. (Unit: mm). |
## Outputs
| Variable | Definition |
|:--|:--|
| pupil_corrected | PFE corrected pupil data. (Unit: unit of the input pupil data). |

## References
[1] Hayes, Taylor R., and Alexander A. Petrov. "Mapping and correcting the influence of gaze position on pupil size measurements." Behavior Research Methods 48.2 (2016): 510-527.


