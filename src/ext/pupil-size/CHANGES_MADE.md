The original library is at https://github.com/ElioS-S/pupil-size . This version has the following changes compared to
the original:

1. Removed all the example codes and data
2. Removed importEDF
3. Made path constructions that are only compatible with Windows cross compatible. Therefore, removed the manual
Windows system condition check.
4. Removed RawFileModel.m and moved the input checks in that file to PupilDataModel.m . Therefore, the library does not
write any file to disk anymore.
5. Added a conditional check to plot segments only if there is at least one segment.
