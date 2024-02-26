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

function [ iOk ] = CEDS64WriteEvents( fhand, iChan, i64Event )
%CEDS64WRITEEVENTS Writes events to event channel
%   [ iOk ] = CEDS64WriteEvents( fhand, iChan, i64Event )
%   Inputs
%   fhand - An integer handle to an open file
%   iChan - An channel number for an event channel
%   i64Event - A vector of 64-bit integer times (in ticks)
%   Outputs
%   iOk - 0 if the data was copied correctly, otherwise a negative error
%   code

if (nargin ~= 3)
    iOk = -22;
    return;
end

n = length(i64Event);
iOk = calllib('ceds64int', 'S64WriteEvents', fhand, iChan, i64Event, n);
end

