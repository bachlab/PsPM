#!/bin/sh
# copy common methods

PROJDIR=$(pwd)

echo "This script must be run from the top level folder of the matlabbatch repository."
echo $PROJDIR

D1CLASSES="@cfg_branch @cfg_choice @cfg_const @cfg_entry @cfg_files @cfg_menu @cfg_repeat"
D2CLASSES="@cfg_exbranch"
# @cfg_branch is the master in-tree class
INCLASSES="@cfg_choice @cfg_mchoice @cfg_repeat"
# The choice and multiple-choice classes share some code with @cfg_branch, other with @cfg_repeat
CHCLASSES="@cfg_choice @cfg_mchoice"

# Files to copy from @cfg_item to all derived classes
DEFILES="subsasgn.m subs_fields.m subsref.m"
# Files to copy from @cfg_branch to all derived classes
DE1FILES="fieldnames.m"
# Files to copy from @cfg_branch to all in-tree classes
INFILES="all_leafs.m all_set.m expand.m fillvals.m list.m showdoc.m tag2cfgsubs.m tagnames.m update_deps.m"
# Files to copy from @cfg_branch to all choice classes
BCFILES="cfg2jobsubs.m checksubs_job.m harvest.m subsasgn_job.m subsref_job.m val2def.m"
# Files to copy from @cfg_choice to cfg_mchoice class
CMFILES="gencode_item.m private/mysubs_fields.m"
# Files to copy from @cfg_repeat to all choice classes
RCFILES="cfg2struct.m clearval.m treepart.m"

for DEFILE in $DEFILES; do
    git status -s $PROJDIR/@cfg_item/$DEFILE|grep -q "^[[:blank:]]*M"
    if [ $? -eq 0 ]; then
	echo "Copying @cfg_item/$DEFILE to all derived classes"
	for DC in $D1CLASSES $D2CLASSES; do
	    cp $PROJDIR/@cfg_item/$DEFILE $PROJDIR/$DC;
	done
    fi
done

for DEFILE in $DE1FILES; do
    git status -s $PROJDIR/@cfg_branch/$DEFILE|grep -q "^[[:blank:]]*M"
    if [ $? -eq 0 ]; then
	echo "Copying @cfg_branch/$DEFILE to all derived classes"
	for DC in $D1CLASSES $D2CLASSES; do
	    cp $PROJDIR/@cfg_branch/$DEFILE $PROJDIR/$DC;
	done
    fi
done

for INFILE in $INFILES; do
    git status -s $PROJDIR/@cfg_branch/$INFILE|grep -q "^[[:blank:]]*M"
    if [ $? -eq 0 ]; then
	echo "Copying @cfg_branch/$INFILE to all in-tree classes"
	for IC in $INCLASSES; do
	    cp $PROJDIR/@cfg_branch/$INFILE $PROJDIR/$IC;
	done
    fi
done

for BCFILE in $BCFILES; do
    git status -s $PROJDIR/@cfg_branch/$BCFILE|grep -q "^[[:blank:]]*M"
    if [ $? -eq 0 ]; then
	echo "Copying @cfg_branch/$BCFILE to all choice classes"
	for CC in $CHCLASSES; do
	    cp $PROJDIR/@cfg_branch/$BCFILE $PROJDIR/$CC;
	done
    fi
done

for CMFILE in $CMFILES; do
    git status -s $PROJDIR/@cfg_choice/$CMFILE|grep -q "^[[:blank:]]*M"
    if [ $? -eq 0 ]; then
	echo "Copying @cfg_choice/$CMFILE to mchoice class"
	cp $PROJDIR/@cfg_choice/$CMFILE $PROJDIR/@cfg_mchoice;
    fi
done

for RCFILE in $RCFILES; do
    git status -s $PROJDIR/@cfg_repeat/$RCFILE|grep -q "^[[:blank:]]*M"
    if [ $? -eq 0 ]; then
	echo "Copying @cfg_repeat/$RCFILE to all choice classes"
	for CC in $CHCLASSES; do
	    cp $PROJDIR/@cfg_repeat/$RCFILE $PROJDIR/$CC;
	done
    fi
done

git status -s $PROJDIR/cfg_ui.fig|grep -q "^[[:blank:]]*M"
if [ $? -eq 0 ]; then
    echo "Repairing cfg_ui.fig"
    $ML2009b -nodisplay -r "addpath('$PROJDIR');hgsave_pre2008a('$PROJDIR/cfg_ui.fig',true);exit"
# handles in .fig files fail at all in 2007b
#$MLR14SP3 -nodisplay -r "addpath('$PROJDIR');cfg_ui_R14SP3;exit"
#rm $PROJDIR/cfg_ui_R14SP3.m
    mv $PROJDIR/cfg_ui_R14SP3.fig $PROJDIR/cfg_ui.fig
fi