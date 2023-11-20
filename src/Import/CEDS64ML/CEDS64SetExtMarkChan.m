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

function [ iOk ] = CEDS64SetExtMarkChan( fhand, iChan, dRate, iType, iRows, iCols, i64Div )
%CEDS64SETEXTMARKCHAN Creates a new extended marker channel
%   [ iOk ] = CEDS64SetTextMarkChan( fhand, iChan, dRate, iType, iRows {, iCols {, i64Div}} )
%   Inputs
%   fhand - An integer handle to an open file
%   iChan - An integer channel number
%   dRate - The rate of the new channel as a double
%   iType - The type of the new channel 6 = wave mark channel, 7 = real
%   mark channel, 8 = text mark channel (use CED64SetTextMark instead?)
%   iRows - Number of rows for the channel
%   iCols - (Optional) Number of columns for the channel, if not supplied
%   defualts to 1
%   i64Div - (Optional) Sets the divide rate for the channel, only used in wavemark
%   channels
%   Outputs 
%   iOk - 0 if the channel was created correctly, otherwise a negative
%   error code.

if (nargin < 5)
    iOk = -22;
    return;
end
if (nargin < 6)
    iCols = 1;
end
if (nargin < 7)
    if (iType == 6)
        iOk = -22;
        return;
    end
    i64Div = 0;
end

iOk = calllib('ceds64int', 'S64SetExtMarkChan', fhand, iChan, dRate, iType, iRows, iCols, i64Div);
end

