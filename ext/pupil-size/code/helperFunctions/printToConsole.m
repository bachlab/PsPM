function printToConsole(lvl,str,varargin)
% printToConsole Prints feedback for the user to the console.
%
%   This is an internal helper script, and is not intended to be called by
%   users.
%
%--------------------------------------------------------------------------
%
%   This code is part of the supplement material to the article:
%
%    Preprocessing Pupil Size Data. Guideline and Code.
%     Mariska Kret & Elio Sjak-Shie. 2018.
%
%--------------------------------------------------------------------------
%
%     Pupil Size Preprocessing Code (v1.1)
%      Copyright (C) 2018  Elio Sjak-Shie
%       E.E.Sjak-Shie@fsw.leidenuniv.nl.
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or (at
%     your option) any later version.
%
%     This program is distributed in the hope that it will be useful, but
%     WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%--------------------------------------------------------------------------

% Params:
lineWidth = 100;
indent_1 = '\n  ';
indent_2 = '\n   > ';
indent_3 = '\n      - ';
indent_4 = '         ¤ ';

% Parse:
switch lvl
    case 'L1'
        prefix = sprintf('\n%s',repmat('=',lineWidth,1));
        str = '';
    case 'L2'
        prefix = sprintf('%s\n',repmat('-',lineWidth,1));
        str = '';
    case 1
        prefix = indent_1;
    case 2
        prefix = indent_2;
    case 3
        prefix = indent_3;
    case 4
        prefix = indent_4;
    otherwise
        error('lvl not recognized.')
end
fprintf([prefix str],varargin{:});

end