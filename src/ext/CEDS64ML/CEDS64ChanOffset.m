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

function [ iOk, dOffsetOut ] = CEDS64ChanOffset( fhand, iChan, dOffsetIn )
%CEDS64CHANOFFSET Gets and sets the offset for a channel
%   [ iOk, dOffsetOut ] = CEDS64SetChanOffset( fhand, iChan, dOffsetIn )
%   fhand - An integer handle to an open file
%   iChan - A channel number
%   dOffsetIn - (Optional) The new offset as a double
%   Output
%   iOk - 0 if the offset was set correctly otherwise a negative error code
%   dOffsetOut - The old offset as a double

if (nargin == 2 || nargin == 3) % always get the offset
    dOffsetTemp = double(0.0);
    [ iOk, dOffsetOut ] = calllib('ceds64int', 'S64GetChanOffset', fhand, iChan, dOffsetTemp);
else
    iOk = -22;
end

% has there been an error?
if iOk < 0
    return;
end

% if not set the offset if we're given
if (nargin == 3)
    iOk = calllib('ceds64int', 'S64SetChanOffset', fhand, iChan, dOffsetIn);
end
end

