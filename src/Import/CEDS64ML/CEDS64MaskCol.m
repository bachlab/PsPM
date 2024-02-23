%{
    Copyright (C) Cambridge Electronic Design Limited 2014
    Author: Tim Bergel
    Web: www.ced.co.uk email: tim@ced.co.uk, softhelp@ced.co.uk

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

function [ iOk, iPrevCol ] = CEDS64MaskCol( maskh, iCol )
%CEDS64MASKCOL Gets and sets the column select of a marker mask
%   [ iOk {, iPrevCol} ] = CEDS64MaskCol( maskh {, iCol} )
%   Inputs
%   maskh -  An integer handle to a mask
%   iCol -  (Optional) 0 to n-1 to select the marker column (n set by
%           channel on which filter will be used.
%   Outputs
%   iOk - 0 if the column was set, otherwise a negative error code
%   iPrevCol - the previous mask column select value

iPrevCol = 0;
iOk = 0;
if (nargin == 1 || nargin == 2) % always get the old mode
    iPrevCol = calllib('ceds64int', 'S64GetMaskCol', maskh);
    if (iPrevCol == -1)     % -1 is value for 'unset'
        iPrevCol = 0;       % so treat as zero (which is what unset does)
    end
else
    iOk = -22;
    return;
end

% has there been an error?
if iPrevCol < 0
    iOk = -22;
    return;
end

% if no error set the new column if we're given one
if (nargin == 2)
    iOk = calllib('ceds64int', 'S64SetMaskCol', maskh, iCol);
end
end

