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

function [ iRead, i64Times, iLevel ] = CEDS64ReadLevels( fhand, iChan, iN, i64From, i64To )
%CEDS64READLEVELS Reads the first iN level events from channel iChan between i64From and i64To
%   [ iRead, i64Times, iLevel ] = CEDS64ReadLevels( fhand, iChan, iN, i64From {, i64To} )
%   Inputs
%   fhand - An integer handle to an open file
%   iChan - A channel number for a Waveform or Realwave channel
%   iN - The maximum number of events to read
%   i64From - The time in ticks of the earliest time you want to read
%   i64To - The time in ticks of the latest time you want to read (optional if not set, read to the end of the channel)
%   Outputs
%   iRead - The number of events points read or a negative error code
%   i64Times - An array of 64-bit integers conatining the times in ticks of the events 
%   iLevel - The parity of the initial level 0 or 1

if (nargin < 4)
    iRead = -22;
    return;
end

if (nargin < 5)
    i64To = -1;
end

outevpointer = zeros(iN,1,'int64');
levelpointer = 0;
[iRead, i64Times, iLevel] = calllib('ceds64int', 'S64ReadLevels', fhand, iChan, outevpointer, iN, i64From, i64To, levelpointer);

if (iRead > 0)
    i64Times(iRead+1:end) = [];
else
    i64Times = [];
end
end

