#!/bin/sh
# save cfg_ui.fig in sufficiently old MATLAB format

if [ $(hostname) = "nz23161" ]; then
    PROJDIR="/export/spm-devel/matlabbatch/branches/mlb_1"
    ML2009b="/usr/local/matlab2009b/bin/matlab"
    MLR14SP3="/usr/local/matlabR14SP3/bin/matlab"
else
    PROJDIR="/data/projects/spm-devel/matlabbatch/branches/mlb_1"
    ML2009b="matlab2009b"
    MLR14SP3="matlabR14SP3"
fi

svn status $PROJDIR/cfg_ui.fig|grep -q "^M"
if [ $? -eq 0 ]; then
    echo "Repairing cfg_ui.fig"
    $ML2009b -nodisplay -r "addpath('$PROJDIR');hgsave_pre2008a('$PROJDIR/cfg_ui.fig',true);exit"
# handles in .fig files fail at all in 2007b
#$MLR14SP3 -nodisplay -r "addpath('$PROJDIR');cfg_ui_R14SP3;exit"
#rm $PROJDIR/cfg_ui_R14SP3.m
    mv $PROJDIR/cfg_ui_R14SP3.fig $PROJDIR/cfg_ui.fig
fi