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

function [ i64ETime ] = CEDS64WriteWave( fhand, iChan, Wave, i64STime )
%CEDS64WRITEWAVE Writes a vector of 16-bit integers or 32-bit floats to a waveform channel
%   [ i64ETime ] = CEDS64WriteWave(  fhand, iChan, i16Wave, i64STime )
%   Inputs
%   fhand - An integer handle to an open file
%   iChan - An integer channel number
%   Wave - A vector of 16-bit integers or floating-point values
%   i64STime - The time in ticks of the first point
%   Outputs
%   i64ETime - If successful, the time in ticks of the next item after the 
%   final one written, otherwisr a negative error message

if (nargin ~= 4)
    i64ETime = -22;
    return;
end

n = length(Wave);
if (isinteger(Wave))
    Wave = int16(Wave);
    i64ETime = calllib('ceds64int', 'S64WriteWaveS', fhand, iChan, Wave, n, i64STime);
else if(isfloat(Wave))
        Wave = single(Wave);
        i64ETime = calllib('ceds64int', 'S64WriteWaveF', fhand, iChan, Wave, n, i64STime);
    else
        i64ETime = -22;
    end
end
end

