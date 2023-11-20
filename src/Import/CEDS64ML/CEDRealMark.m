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

classdef CEDRealMark < CEDMarker
    
    properties (GetAccess = public, SetAccess = private)
        m_Data;
    end
    
    methods
        function obj = CEDRealMark(Time, Code1, Code2, Code3, Code4, Reals)
            % class constructor
            obj = obj@CEDMarker();
            obj.m_Data = zeros(0,0,'single');
            if(nargin > 0)
                obj.m_Time = int64(Time);
            end
            if(nargin > 1)
                obj.m_Code1 = uint8(Code1(1));
            end
            if(nargin > 2)
                obj.m_Code2 = uint8(Code2(1));
            end
            if(nargin > 3)
                obj.m_Code3 = uint8(Code3(1));
            end
            if(nargin > 4)
                obj.m_Code4 = uint8(Code4(1));
            end
            if(nargin > 5)
                if (isnumeric(Reals) && ismatrix(Reals))
                    obj.m_Data = single(Reals);
                end
            end
        end
        
        function [ r, c ] = Size(obj)
            [ r, c ] = size(obj.m_Data);
        end
        
        function D = GetData(obj)
            D = obj.m_Data;
        end
        
        function err = SetData(obj, Reals)
            err = 0;
            if (isnumeric(Reals) && ismatrix(Reals))
                obj.m_Data = single(Reals);
            else
                err = -22;
            end
        end
    end
end