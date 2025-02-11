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

function [ iVersion ] = CEDS64Version( fhand )
%CEDS64VERSION Get the file version number
%   [ version ] = CEDS64Version( fhand )
%   Inputs
%   fhand - An integer handle to an open file
%   Outputs
%   iVersion -  The version number of the file. Versions 1 to 8 are 32-bit
%   files with a maximum size of 2 GB. Version 9 is a 32-bit file with a
%   maximum size of 1 TB. Versions 256 and later are 64-bit files.

if (nargin ~= 1)
    iVersion = -22;
    return;
end

iVersion = calllib('ceds64int', 'S64GetVersion', fhand);
end

