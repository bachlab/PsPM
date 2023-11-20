%{
    Copyright (C) Cambridge Electronic Design Limited 2014
    Author: James Thompson
    Web: www.ced.co.uk email: james@ced.co.uk, softhelp@ced.co.uk

    This file is part of CEDS64ML, a MATLAB interface to the SON64 library.

    CEDS64ML is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    CEDS64ML is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with CEDS64ML.  If not, see <http://www.gnu.org/licenses/>.
%}

function [ iPre, iRows, iCols ] = CEDS64GetExtMarkInfo( fhand, iChan )
%CEDS64GETEXTMARKINFO Gets number of rows and columns from an extended
%marker channel
%   [ iPre, iRows, iCols ] = CEDS64GetExtMarkerInfo( fhand, iChan )
%   Inputs
%   fhand - Integer file handle
%   iChan - Channel number of an extended marker channel
%   Outputs
%   iPre - The number of pre-alignment points (only used in wavemark channels)
%   otherwise a negative error code.
%   iRows - The number of rows
%   iCols - The number of columns

if(nargin == 2)
    RowPtr = 0;
    ColPtr = 0;
    [ iPre, iRows, iCols ] = calllib('ceds64int', 'S64GetExtMarkInfo', fhand, iChan, RowPtr, ColPtr);
else
    iPre = -22;
end
end

