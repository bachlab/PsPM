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

function [ i64Time ] = CEDS64PrevNTime( fhand, iChan, i64From, i64To, iN, maskh, bAsWave )
%CEDS64PREVNTIME Returns the time in ticks of the iNth item AFTER time 
%   i64From but BEFORE i64To. If there aren't iN items between i64To and
%   i64From returns -1
%   [ i64Time ] = CEDS64PrevNTime( fhand, iChan, i64From {, i64To {, iN {, maskh {, bAsWave}}}} )
%   Inputs
%   fhand - An integer handle to an open file
%   iChan - An integer channel number
%   i64From - The UPPER bound of the time range
%   i64To - (Optional) The LOWER bound of the range, if not given it is set to 0
%   iN - (Optional) The number of items to go back, if not given it is set to 1
%   maskh - (Optional) An integer handle to a marker mask
%   bAsWave - (Optional) Only used for extended marker channels, 0 - read 
%   the data as events, 1 - read the data as a wave if not given it is set
%   to 1, read as events
%   Outputs
%   i64Time - The time in ticks of the item, -1 if no item in the range or
%   a negative error code.

if (nargin < 3)
    i64Time = -22;
    return;
end

if (nargin < 4)
    i64To = 0;
end

if (nargin < 5)
    iN = 1;
end

if (nargin < 6)
    maskcode = -1;
else
    maskcode = maskh;
end

if (nargin < 7)
    bAsWave = 0;
end
    

i64Time = calllib('ceds64int', 'S64PrevNTime', fhand, iChan, i64From, i64To, iN, maskcode, bAsWave);

end

