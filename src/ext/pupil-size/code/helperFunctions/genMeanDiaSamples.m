function meanDia = genMeanDiaSamples(t_ms,L_dia,R_dia,L_valid,R_valid)
% genMeanDiaSamples Calculates the mean pupil diameter.
%
%   meanDia = genMeanDiaSamples(t_ms,L_dia,R_dia,L_valid,R_valid)
%
%    t_ms is the timevector in ms.
%
%    L_dia & L_valid, the left pupil diameters and a logical vector
%    indicating which of those samples are valid, respectively.
%
%    R_dia & R_valid, the right diameters and a logical vector indicating
%    which of those samples are valid, respectively.
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


%% Preprocess Input:

% Get raw samples and set unaccepted samples to NaN:
L_dia(~L_valid)  = NaN;
R_dia(~R_valid)  = NaN;

% Identify all the single pupil data rows:
LwithoutR        = ~isnan(L_dia)&isnan(R_dia);
RwithoutL        = ~isnan(R_dia)&isnan(L_dia);

% Get the difference between the left and right diameters:
diamDiff      = (R_dia-L_dia);
diamDiffRows  = ~isnan(diamDiff);


%% Generate Mean Diameter:

% Calculate the fixed left and right pupil diameters (i.e. the diameters
% including those regenerated using samples from the other eye):
if sum(diamDiffRows)>2
    
    % Interpolate the differences to the full time vector:
    diamDiffCont = interp1(t_ms(diamDiffRows)...
        ,diamDiff(diamDiffRows)...
        ,t_ms,'linear');
    
    % Synthesize data for the left eye when data for the right is available
    % using the previously calculated difference:
    L_fixed = L_dia;
    L_fixed(RwithoutL) = R_dia(RwithoutL)...
        -diamDiffCont(RwithoutL);
    
    % Same for other pupil:
    R_fixed = R_dia;
    R_fixed(LwithoutR) = L_dia(LwithoutR)...
        +diamDiffCont(LwithoutR);

    % Calculate the mean diameters:
    meanDia = mean([L_fixed R_fixed],2);
 
else
    
    meanDia = [];
    
end


end