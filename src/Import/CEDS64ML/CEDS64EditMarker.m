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

function [ iOk ] = CEDS64EditMarker( fhand, iChan, i64Time, cMarker )
%CEDS64EDITMARKER Copies the marker codes in cMarker to the first marker 
%   before time i64Time in channel iChan (note this does not allow you to 
%   change the time of an existing marker)
%   [ iOk ] = CEDS64EditMarker( fhand, iChan, i64Time, cMarker )
%   Inputs
%   fhand - An integer handle to an open file
%   iChan - An integer channel number
%   i64Time - Time in ticks
%   cMarker - The marker to be copied
%   Outputs
%   iOk - 0 if the data was copied correctly, otherwise a negative error
%   code.
if(nargin == 4)
    iOk = calllib('ceds64int', 'S64EditMarker', fhand, iChan, i64Time, cMarker);
else
    iOk = -22;
end
end

