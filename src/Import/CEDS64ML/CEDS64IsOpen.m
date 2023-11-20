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

function [ iOpen ] = CEDS64IsOpen( fhand )
%CEDS64ISOPEN Checks if there is file currently open with handle fhand
%   [ iOpen ] = CEDS64IsOpen( fhand )
%   Inputs
%   fhand - An integer handle to an open file
%   Outputs
%   iOpen - 1 if there is a file with this handle, 0 otherwise.

if (nargin ~= 1)
    iOpen = -22;
    return;
end

iOpen = calllib('ceds64int', 'S64IsOpen', fhand);
end

