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

function [ iOk, AppIDOut ] = CEDS64AppID( fhand, AppIDIn )
%CEDS64APPID Sets and gets Application ID
%   [ iOk, AppIDOut ] = CEDS64AppID( fhand {, AppIDIn} )
%   Inputs
%   fhand An integer file handle to identify the file. 
%   AppIDIn (Optional) If present the application ID field will be changed.
%   This is either a string (in which case the first 8 characters will be
%   used) or a vector of integers (which will be converted to uint8). If
%   the passed in data is less than 8 character/values the space is made up
%   with zeros. 
%   Outputs
%   AppIDOut - A vector of 8uints containing the Application ID
%   iOk Returned as 0 if the operation completed without error, otherwise a negative error code. 


AppIDOut = blanks(8);
if (nargin == 1 || nargin == 2) % get the old AppID
    BufferIn = zeros(1, 8, 'int8');
    BufferOut = zeros(1, 8, 'int8');
    [ iOk, AppIDOut ] = calllib('ceds64int', 'S64AppID', fhand, BufferOut, BufferIn, -1);
    AppIDOut = abs(AppIDOut);
else
   iOk = -22;
   return;
end

% set the new TimeDate if we're given one
if (nargin == 2)
    AppIDIn = uint8(AppIDIn);
    AppIDIn = reshape(AppIDIn, [], 1 );

    if (length(AppIDIn) > 8)
        AppIDIn = AppIDIn(1:8);
    end
    if (length(AppIDIn) < 8)
        AppIDIn(8) = 0;
    end
    BufferOut = zeros(1, 8, 'int8');
    %AppIDIn = char(AppIDIn);
    [ iOk ] = calllib('ceds64int', 'S64AppID', fhand, BufferOut, AppIDIn, 0);
end
end

