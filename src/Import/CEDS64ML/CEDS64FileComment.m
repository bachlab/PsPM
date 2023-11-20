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

function [ iOk, sCommentOut ] = CEDS64FileComment( fhand, iIndex, sCommentIn )
%CEDS64FILECOMMENT gets and sets the a file comment
%   [ iOk, sCommentOut ] = CEDS64FileComment( fhand, iIndex {, sCommentIn } )
%   Inputs
%   fhand - An integer handle to an open file
%   iIndex - The index of the comment to Set (1-5)
%   sCommentIn - (Optional) A string containing the new comment
%   Outputs
%   iOk - 0 if the comment was set correctly, otherwise a negative error
%   code.
%   sCommentOut - A string containing the old comment

if (nargin == 2 || nargin == 3) % always get the old comment
    %step 1 find out how big the comment is
    dummystring = blanks(1);
    [iSize] = calllib('ceds64int', 'S64GetFileComment', fhand, iIndex, dummystring, -1);
    %step 2 create a string buffer of the correct size
    stringptr = blanks(iSize+1);
    [iOk, sCommentOut] = calllib('ceds64int', 'S64GetFileComment', fhand, iIndex, stringptr, 0);
else
    iOk = -22;
end

% has there been an error?
if iOk < 0
    return;
end

% if not set the new comment if we're given one
if (nargin == 3)
    iOk = calllib('ceds64int', 'S64SetFileComment', fhand, iIndex, sCommentIn);
end
end

