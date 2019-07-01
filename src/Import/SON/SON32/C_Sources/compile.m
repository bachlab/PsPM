% COMPILE Script file to compile c-code sources and generate the DLLs
% To compile the files, you will need copies of CED's machine.h and son.h.
% These are proprietory and not included in the distribution. Contact CED.
%

mex -v SONGetADCData.c GetFilterMask.c
mex -v SONGetRealData.c GetFilterMask.c
mex -v SONGetMarkData.c GetFilterMask.c
mex -v SONGetExtMarkData.c GetFilterMask.c
mex -v SONGetEventData.c GetFilterMask.c
mex -v SONFEqual.c GetFilterMask.c
mex -v SONFActive.c GetFilterMask.c
mex -v SONFControl.c GetFilterMask.c
mex -v SONFMode.c GetFilterMask.c
mex -v SONFilter.c GetFilterMask.c
mex -v SONLastTime.c GetFilterMask.c
mex -v SONLastPointsTime.c GetFilterMask.c
mex -v SONSetMarker.c
mex -v SONTimeDate.c
mex -v SONAppID.c
mex -v gatewaySONWriteExtMarkBlock.c

