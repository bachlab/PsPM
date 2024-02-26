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

function [ iOk, dYLowOut, dYHighOut  ] = CEDS64ChanYRange( fhand, iChan, dYlowIn, dYHighIn )
%CEDS64CHANYRANGE Gets and set the Y-range for a channel
%   [ iOk{, dYLowOut, dYHighOut}  ] = CEDS64ChanYRange( fhand, iChan {, dYlowIn, dYHighIn} )
%   Inputs
%   fhand - An integer file handle to identify the file. 
%   iChan - The channel number (starting at 1). 
%   dYlowIn - (Optional) If present, the new channel low value. If omitted,
%   no change is made. 
%   dYHighIn - (Optional) If present, the new channel high value. If
%   omitted, no change is made. 
%   Ouputs
%   iOk - 0 if the operation completed without error, otherwise a negative
%   error code. 
%   dYLowOut If present, returned as the original low value before any
%   change made by dNewLo. 
%   dYHighOut If present, returned as the original high value before any
%   change made by dNewHi. 


if (nargin == 2 || nargin == 4) % always get the old Y range
    dYLowTemp = double(0.0);
    dYHighTemp = double(0.0);
    [ iOk, dYLowOut, dYHighOut ] = calllib('ceds64int', 'S64GetChanYRange', fhand, iChan, dYLowTemp, dYHighTemp);
else
    iOk = -22;
end

% has there been an error?
if iOk < 0
    return;
end

% if not set the new Y range if we're given one
if (nargin == 4)
    iOk = calllib('ceds64int', 'S64SetChanYRange', fhand, iChan, dYlowIn, dYHighIn);
end
end

