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

function [ iOk, iCodesOut ] = CEDS64MaskCodes( maskh, iCodesIn )
%CEDS64MASKCODES Gets and sets the codes for a filter mask
%   [ iOk {, iCodesOut} ] = CEDS64MaskCodes( maskh {, iCodesIn} )
%   Inputs
%   maskh - an Integer handle to a mask
%   iCodesIn - (Optional) A 256-by-4 matrix. If the i-jth entry is non-zero,
%   then item i in layer j of the mask is included in the mask
%   Outputs
%   iOk - 0 if codes returned correctly else a negetive error code
%   iCodesOut - either a uint8 256-by-4 matrix of 0s and 1s representing the
%   mask code if we're getting the codes or 0 if we're se

iCodesOut = 0;
iOk = -22;
if (nargin == 1) % we're getting codes
    outcodepointer = zeros(256,4,'int32');
    outmodepointer = 0;
    [ iOk, iCodesOut ] = calllib('ceds64int', 'S64GetMaskCodes', maskh, outcodepointer, outmodepointer);
end

if (nargin ==2) %we're setting codes
    if ( ~ismatrix(iCodesIn) )
        iOk = -22;
        return;
    end
    
    [ m, n ] = size(iCodesIn); % check we've been passed a correct matrix
    if (m < 256)
        iCodesIn(256,4) = 0;
    else if (m > 256)
            iCodesIn = iCodesIn(1:256,:);
        end
    end
    
    if (n < 4)
        iCodesIn(256,4) = 0;
    else if (n > 4)
            iCodesIn = iCodesIn(:,1:4);
        end
    end
    
    iCodesIn = reshape(iCodesIn, [], 1 );
    if (isinteger(iCodesIn))
        [ iOk ] = calllib('ceds64int', 'S64SetMaskCodes', maskh, iCodesIn);
    else
        iOk = -22;
    end
end
end

