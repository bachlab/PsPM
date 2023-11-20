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

function [ dSeconds ] = CEDS64TicksToSecs( fhand, i64Ticks )
%CEDS64TICKSTOSECS Converts ticks to seconds
%   [ dSeconds ] = CEDS64TicksToSecs( fhand, i64Ticks )
%   Inputs
%   fhand - An integer handle to an open file
%   i64Ticks - The time in ticks as a 64-bit integer
%   Outputs
%   dSeconds - The time in seconds as a double, or a number <= 0 if an error.

if (nargin ~= 2)
    dSeconds = -22;
    return;
end

if (length(i64Ticks) > 1)
    [ dTimeBase] = CEDS64TimeBase(fhand);
    if (dTimeBase > 0)
        dSeconds = double(i64Ticks) * dTimeBase;
    else
        dSeconds = dTimeBase;
    end
else
    dSeconds = calllib('ceds64int', 'S64TicksToSecs', fhand, i64Ticks);
end

end