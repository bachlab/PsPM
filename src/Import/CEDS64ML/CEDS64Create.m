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

function [ fhand ] = CEDS64Create( sFileName, iChans, iType )
%CEDD64CREATE Creates a new SON File
%   [ fhand ] = CEDD64Create( sFileName {, iChans {, iType}} )
%   Input Values
%   sFileName - String containing the path and filename for the new file
%   iChans - (Optional) The maximum number of chans the file can have. If 
%   not supplied the number of channels defaults to 32
%   iType - (Optional) The type of the file 0 = small 32-bit .smr,
%   1 = big 32-bit .smr, 2 = 64-bit .smrx. If not supplied the file type is
%   determined by file extension, if no suffix is given the file type is smrx.
%   Output Value
%   fhand - An integer handle for the file,otherwise a negative error code.

if (nargin < 1)
    fhand = -22;
    return;
end

if (nargin < 3)
    iType = -1;
    
end

if (nargin < 2)
    iChans = 32;
end

fhand = calllib('ceds64int', 'S64Create', sFileName, iChans, iType);
end

