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

function [ ] = CEDS64ErrorMessage( iErrorCode )
%CEDS64ERRORMESSAGE This function converts integer error codes into warnings
%describing the errors in plain english.
%   [ ] = CEDS64ErrorMessage( iErrorCode )
%   Inputs
%   iErrorCode - An negative integer code.
%   Outputs nothing, just generates a warning
if (isnumeric(iErrorCode) && iErrorCode < 0)
    %step 1 find out how big the title is is
    dummystring = blanks(1);
    [iSize] = calllib('ceds64int', 'S64GetErrorMessage', iErrorCode, dummystring, -1);
    %step 2 create a string buffer of the correct size
    errmsg = blanks(iSize+1);
    calllib('ceds64int', 'S64GetErrorMessage', iErrorCode, errmsg, 0);
    %step 3 generate the warning message
    warning(errmsg);
end
end

