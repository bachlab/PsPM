function Ver=SONVersion()
% SONVERSION returns the MATLAB library version number (Not a CED function)
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London

global Version;
title='MATLAB SON Library';

st=sprintf(['\nMATLAB SON Library for Windows:\n',...
    'Author: Malcolm Lidierth, ',...
    '\n01.06.05   Version:%3.2f %cKing%cs College London\n\n',...
    'SON Filing system Copyright %c Cambridge Electronic Design 1988-2005\nVersion 7.0'],Version,169,39,169);

msgbox(st,title,'modal');
Ver=Version;