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

function [ iRead, ExtMarkers ] = CEDS64ReadExtMarks( fhand, iChan, iN,  i64From, i64To, maskh )
%CEDS64READEXTMARKS Reads extended marker data from a extended marker channels
%   [ iRead, ExtMarkers ] = CEDS64ReadExtMarks( fhand, iChan, iN,  i64From {, i64To {, maskh}} )
%   Inputs
%   fhand - An integer handle to an open file
%   iChan - A channel number for an extended event channel
%   iN - The maximum number of data points to read
%   i64From - The time in ticks of the earliest time you want to read
%   i64To - (Optional) The time in ticks of the latest time you want to
%   read. If not set or set to -1, read to the end of the channel
%   maskh -  (Optional) An integer handle to a marker mask
%   Outputs
%   iRead - The number of data points read or a negative error code
%   ExtMarkers - An array of CED64Markers

if (nargin < 4)
    iRead = -22;
    return;
end

Type = calllib('ceds64int', 'S64ChanType', fhand, iChan);
Size = calllib('ceds64int', 'S64ItemSize', fhand, iChan);
Time = int64(i64From);
Count = 0;
if (Size < 0)
    return;
end

if (nargin < 5 || i64To < 0)
    i64Upto = -1;
    i64To = CEDS64MaxTime(fhand) +1;
else
    i64Upto = i64To;
end

if (nargin < 6)
    maskcode = -1;
else
    maskcode = maskh;
end

switch (Type)
    case 8 %textmarker
        [ iOk, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand, iChan );
        if ( (iOk < 0) || (Cols ~= 1) ), return; end
        StrLen = (Rows); % calculate the length of the string
        InMarker = struct(CEDMarker());
        stringptr =  blanks(StrLen+8);
        ExtMarkers(iN,1) = CEDTextMark();               % resize in one operation
        for n=1:iN
            if (Time >= i64To)
                break;
            end
            [ iRead, OutMarker, sText ] = calllib('ceds64int', 'S64Read1TextMark', fhand, iChan, InMarker, stringptr, Time, i64Upto, maskcode);
            if (iRead > 0)
                Count = Count + 1;
                ExtMarkers(n,1) = CEDTextMark();
                ExtMarkers(n,1).SetTime( OutMarker.m_Time );
                ExtMarkers(n,1).SetCode( 1, OutMarker.m_Code1 );
                ExtMarkers(n,1).SetCode( 2, OutMarker.m_Code2 );
                ExtMarkers(n,1).SetCode( 3, OutMarker.m_Code3 );
                ExtMarkers(n,1).SetCode( 4, OutMarker.m_Code4 );
                ExtMarkers(n,1).SetData(sText);
                Time = OutMarker.m_Time + 1;
            else
                break;
            end
        end
        if Count > 0
            ExtMarkers(Count+1:end) = [];
        else
            ExtMarkers = [];
        end
    case 7 %realmarker
        [ iOk, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand, iChan );
        if iOk < 0, return; end
        Reals = Rows * Cols;
        InMarker = struct(CEDMarker());
        floatptr = zeros(Reals,1,'single');
        ExtMarkers(iN,1) = CEDRealMark();               % resize in one operation
        for n=1:iN
            if (Time >= i64To)
                break;
            end
            [ iRead, OutMarker, dReal ] = calllib('ceds64int', 'S64Read1RealMark', fhand, iChan, InMarker, floatptr, Time, i64Upto, maskcode);
            if (iRead > 0)
                Count = Count + 1;
                ExtMarkers(n,1) = CEDRealMark();
                ExtMarkers(n,1).SetTime( OutMarker.m_Time );
                ExtMarkers(n,1).SetCode( 1, OutMarker.m_Code1 );
                ExtMarkers(n,1).SetCode( 2, OutMarker.m_Code2 );
                ExtMarkers(n,1).SetCode( 3, OutMarker.m_Code3 );
                ExtMarkers(n,1).SetCode( 4, OutMarker.m_Code4 );
                ExtMarkers(n,1).SetData(reshape(dReal, Rows, Cols));
                Time = OutMarker.m_Time + 1;
            else
                break;
            end
        end
        if Count > 0
            ExtMarkers(Count+1:end) = [];
        else
            ExtMarkers = [];
        end
    case 6 %wavemarkers
        [ iOk, Rows, Cols ] = CEDS64GetExtMarkInfo( fhand, iChan );
        if iOk < 0, return; end
        Wave = Rows * Cols;
        InMarker = struct(CEDMarker());
        singleptr = zeros(Wave,1,'int16');
        ExtMarkers(iN,1) = CEDWaveMark();               % resize in one operation
        for n=1:iN
            if (Time >= i64To)
                break;
            end
            [ iRead, OutMarker, i16Wave ] = calllib('ceds64int', 'S64Read1WaveMark', fhand, iChan, InMarker, singleptr, Time, i64Upto, maskcode);
            if (iRead > 0)
                Count = Count + 1;
                ExtMarkers(n,1) = CEDWaveMark();
                ExtMarkers(n,1).SetTime( OutMarker.m_Time );
                ExtMarkers(n,1).SetCode( 1, OutMarker.m_Code1 );
                ExtMarkers(n,1).SetCode( 2, OutMarker.m_Code2 );
                ExtMarkers(n,1).SetCode( 3, OutMarker.m_Code3 );
                ExtMarkers(n,1).SetCode( 4, OutMarker.m_Code4 );
                ExtMarkers(n,1).SetData(transpose(reshape(i16Wave, Cols, Rows)));
                Time = OutMarker.m_Time + 1;
            else
                break;
            end
        end
        if Count > 0
            ExtMarkers(Count+1:end) = [];
        else
            ExtMarkers = [];
        end
    otherwise
        iRead = -1;
end
iRead = Count;
end

