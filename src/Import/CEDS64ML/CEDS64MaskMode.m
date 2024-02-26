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

function [ iOk, iPrevMode ] = CEDS64MaskMode( maskh, iMode )
%CEDS64MASKMODE Gets and sets the mode of a marker mask (AND or OR)
%   [ iOk {, iPrevMode} ] = CEDS64MaskMode( maskh {, iMode} )
%   Inputs
%   maskh -  An integer handle to a mask
%   iMode - (Optional) 0 for AND mode, 1 for OR mode
%   Outputs
%   iOk - 0 if the mask mode was set, otherwise a negative error code
%   iPrevMode - the previous mask mode

iPrevMode = 0;
iOk = 0;
if (nargin == 1 || nargin == 2) % always get the old mode
    iPrevMode = calllib('ceds64int', 'S64GetMaskMode', maskh);
else
    iOk = -22;
    return;
end

% has there been an error?
if iPrevMode < 0
    iOk = -22;
    return;
end

% if not set the new title if we're given one
if (nargin == 2)
    if ( (iMode == 0) || (iMode == 1) )
        iOk = calllib('ceds64int', 'S64SetMaskMode', maskh, iMode);
    else
        iOk = -22;
    end
end
end

