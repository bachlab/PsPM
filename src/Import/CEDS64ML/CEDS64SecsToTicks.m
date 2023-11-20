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

function [ i64Ticks ] = CEDS64SecsToTicks( fhand, dSeconds )
%CEDS64SECSTOTICKS Converts seconds to ticks
%   [ i64Ticks ] = CEDS64TicksToSecs( fhand, dSeconds )
%   Inputs
%   fhand - An integer handle to an open file
%   dSeconds - The time in seconds as a double
%   Outputs
%   i64Ticks - The time in ticks as a 64-bit integer, or a number <= 0 if an error.

if (nargin ~= 2)
    i64Ticks = -22;
    return;
end

if (length(dSeconds) > 1)
    [ dTimeBase ] = CEDS64TimeBase(fhand);
    if (dTimeBase > 0)
        i64Ticks = int64(dSeconds / dTimeBase);
    else
        i64Ticks = int64(dTimeBase);
    end
else
    i64Ticks = calllib('ceds64int', 'S64SecsToTicks', fhand, dSeconds);
end
end

