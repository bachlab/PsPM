classdef ValidSamplesModel < handle
    %ValidSamplesModel Data model for processing valid samples.
    %
    %   obj = ValidSamplesModel(eye,hPupilDataModel,samples...
    %         ,validFraction);
    %
    %    eye must be either 'left' or 'right', indicating which eye the
    %    data in the current instance represents.
    %
    %    hPupilDataModel is a handle to the PupilDataModel parent.
    %
    %    samples is a struct with the 't_ms' and 'pupilDiameter' fields
    %    that hold the timestamps and concerning valid pupilsize samples.
    %
    %    validFraction is a metric to track the fraction of the usable
    %    raw samples that were deemed valid.
    %
    %----------------------------------------------------------------------
    %
    %   This code is part of the supplement material to the article:
    %
    %    Preprocessing Pupil Size Data. Guideline and Code.
    %     Mariska Kret & Elio Sjak-Shie. 2018.
    %
    %----------------------------------------------------------------------
    %
    %     Pupil Size Preprocessing Code (v1.1)
    %      Copyright (C) 2018  Elio Sjak-Shie
    %       E.E.Sjak-Shie@fsw.leidenuniv.nl.
    %
    %     This program is free software: you can redistribute it and/or
    %     modify it under the terms of the GNU General Public License as
    %     published by the Free Software Foundation, either version 3 of
    %     the License, or (at your option) any later version.
    %
    %     This program is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    %     General Public License for more details.
    %
    %     You should have received a copy of the GNU General Public License
    %     along with this program.  If not, see
    %     <http://www.gnu.org/licenses/>.
    %
    %----------------------------------------------------------------------
    
    
    %% Properties:
    
    properties
        
        hPupilDataModel;
        eye;
        validFraction;
        samples = struct('t_ms',[],'pupilDiameter',[]);
        signal  = struct('t',[],'pupilDiameter',[],'gap',[]);
        
    end
    
    properties (Dependent)
        settings;
    end
    
    
    %% Dynamic Methods:
    
    methods
        
        
        %==================================================================
        function obj = ValidSamplesModel(eye,hPupilDataModel...
                ,samples,validFraction)
            % Constructs a ValidSamplesModel object.
            %
            %--------------------------------------------------------------
            
            % Save input:
            if nargin~=0
                obj.eye              = eye;
                obj.hPupilDataModel  = hPupilDataModel;
                obj.samples          = samples;
                obj.validFraction = validFraction;
                
                % Process data:
                obj.interpAndSmooth;
                
            end
        end
        
        
        %==================================================================
        function valOut = get.settings(obj)
            % Gets settings from the parent.
            %
            %--------------------------------------------------------------
            if ~isempty(obj.hPupilDataModel)...
                    &&isfield(obj.hPupilDataModel.settings...
                    ,'valid')
                valOut = obj.hPupilDataModel.settings.valid;
            else
                valOut = struct();
            end
        end
        
        
        %==================================================================
        function interpAndSmooth(obj)
            % Gets Interpolates and smoothes the samples.
            %
            %--------------------------------------------------------------
            
            % Check settings:
            assert(~isempty(obj.settings),'No settings present.')
            
            % Interpolate the valid samples to form the signal:
            validDiams             = obj.samples.pupilDiameter;
            valid_t_ms             = obj.samples.t_ms;
            
            % Verify inputs:
            if length(validDiams)<2
                error('Interpolation cannot be performed.')
            end
            
            % Generate the upsampled time vector (seconds):
            t_upsampled = ...
                (valid_t_ms(1)/1000 ...
                :(1/obj.settings.interp_upsamplingFreq)...
                :valid_t_ms(end)/1000)';
            diaInterp = interp1(valid_t_ms./1000 ...
                ,validDiams...
                ,t_upsampled,'linear');
            
            % Filter:
            diaInterp = filtfilt(obj.settings.LpFilt_B...
                ,obj.settings.LpFilt_A...
                ,diaInterp);
            
            % Calculate the gaps (the edges dont really matter, samples
            % close to the edges wil be given a gap of 0 subsequently).
            % NOTE: for backwards compatibility, histc is used in lieu of
            % discretize. With newer MATLAB, you could instead use:
            %   gaps_msB = discretize(t_upsampled.*1000 ...
            %    ,valid_t_ms,diff(valid_t_ms));
            valz          = [diff(valid_t_ms);NaN];
            valz(end)     = valz(end-1);
            [~,binzIndxA] = histc(t_upsampled.*1000, valid_t_ms);
            gaps_ms       = valz(binzIndxA);

            % Set samples that are really close to the raw samples as
            % having no gap (scale the closeness with the sampling freq.).
            % In this case it is set to half the sampling interval:
            notTouchingYouTolerance_ms = (0.5*1000)...
                /obj.settings.interp_upsamplingFreq;
            
            % NOTE: The command histc is used for backwards compatibility,
            % in MATLAB 2015a and newer you could instead use:
            %  almostTouching = ismembertol(t_upsampled.*1000,valid_t_ms...
            %  ,notTouchingYouTolerance_ms,'DataScale',1);
            %
            % Generate edges using the timestamps of the valid samples, +/-
            % the tolerance and use histc to place the upsampled timestamps
            % in the bins. Since MATLAB generates bins between all edges,
            % test only for even-bins hit. Those hits will signify that a
            % upsampled timestamp was within the tolerance of a valid
            % measured datapoint:
            binz = bsxfun(@plus ...
                ,valid_t_ms,[-1 1] .* notTouchingYouTolerance_ms)';
            [~,binHits] = histc(t_upsampled.*1000 ...
                , binz(:));
            almostTouching = mod(binHits,2);
            
            % Now actually set the upsampled timestamps that are really
            % close to the timestamps of the valid measured datapoints to
            % zero:
            gaps_ms(logical(almostTouching)) = 0;
            
            % Remove gaps:
            diaInterp(gaps_ms > obj.settings.interp_maxGap) = NaN;
            
            % Save data to model:
            obj.signal.t             = t_upsampled;
            obj.signal.pupilDiameter = diaInterp;
            obj.signal.gap_ms        = gaps_ms;
            
        end
        
        %==================================================================
        function statsTable = analyze(obj,segmentData)
            % Analyzes the segments.
            %
            %--------------------------------------------------------------
            
            % Check and parse input:
            assert(isscalar(obj),'Nope, this is a scalar function!');
            segmentCount      = size(segmentData,1);
            if segmentCount == 0
                statsTable = table();
                return
            end
            
            % Define the metrics:
            dataNamePrefix = [obj.eye 'Pupil_'];
            metricsCell = {...
                [dataNamePrefix 'SmoothSig_meanDiam']        'mm'...
                ['The mean ' obj.eye ' pupil diameter'...
                ', calculated per segment from'...
                ' the interpolated and filtered signal.'];...
                ...
                [dataNamePrefix 'SmoothSig_minDiam']         'mm'...
                ['The minimum ' obj.eye ' pupil diameter'...
                ', calculated per segment from'...
                ' the interpolated and filtered signal.'];...
                ...
                [dataNamePrefix 'SmoothSig_maxDiam']         'mm'...
                ['The maximum ' obj.eye ' pupil diameter'...
                ', calculated per segment from'...
                ' the interpolated and filtered signal.'];...
                ...
                [dataNamePrefix 'SmoothSig_missingDataPercent'] '%'...
                ['The percentage of missing data in the '...
                obj.eye ' pupil diameter''s interpolated and filtered'...
                ' signal.'];...
                ...
                [dataNamePrefix 'SmoothSig_sampleCount']      '-'...
                ['The total number of samples (including ones without'...
                ' data) of the ' obj.eye ' pupil diameter''s'...
                ' interpolated and filtered signal inside the'...
                ' segment.'];...
                ...
                ...
                ...
                [dataNamePrefix 'ValidSamples_meanDiam']     'mm'...
                ['The mean ' obj.eye ' pupil diameter'...
                ', calculated per segment from'...
                ' the valid samples.'];...
                ...
                [dataNamePrefix 'ValidSamples_minDiam']      'mm'...
                ['The minimum ' obj.eye ' pupil diameter'...
                ', calculated per segment from'...
                ' the valid samples.'];...
                ...
                [dataNamePrefix 'ValidSamples_maxDiam']      'mm'...
                ['The maximum ' obj.eye ' pupil diameter'...
                ', calculated per segment from'...
                ' the valid samples.'];...
                ...
                [dataNamePrefix 'ValidSamples_validPercent'] '%'...
                ['The overall percentage of ' obj.eye ' raw samples'...
                ' that were valid (not segment specific).'];...
                ...
                [dataNamePrefix 'ValidSamples_sampleCount']    '-'...
                ['The total number of ' obj.eye ' pupil valid'...
                ' samples inside the segment.'];...
                };
            
            % Generate table:
            statsTable = array2table(NaN(segmentCount...
                ,size(metricsCell,1)));
            statsTable.Properties.VariableNames = metricsCell(:,1);
            statsTable.Properties.VariableUnits = metricsCell(:,2);
            statsTable.Properties.VariableDescriptions = metricsCell(:,3);
            
            % Analyze segments:
            segmentStart    = segmentData.segmentStart;
            segmentEnd      = segmentData.segmentEnd;
            for segmentIndx = 1:segmentCount
                if isnan(segmentStart(segmentIndx))...
                        ||isnan(segmentEnd(segmentIndx))
                    continue;
                end
                
                %----------------------------------------------------------
                
                % Get segment indexes of smooth signal:
                curSignalSection = ...
                    (obj.signal.t >= segmentStart(segmentIndx))...
                    &(obj.signal.t < segmentEnd(segmentIndx));
                
                if sum(curSignalSection) > 0
                    
                    % Analyze smooth signal descriptive stats:
                    statsTable.([dataNamePrefix ...
                        'SmoothSig_meanDiam'])(segmentIndx) ...
                        = nanmean(...
                        obj.signal.pupilDiameter(curSignalSection));
                    statsTable.([dataNamePrefix ...
                        'SmoothSig_minDiam'])(segmentIndx) ...
                        = min(...
                        obj.signal.pupilDiameter(curSignalSection));
                    statsTable.([dataNamePrefix ...
                        'SmoothSig_maxDiam'])(segmentIndx) ...
                        = max(...
                        obj.signal.pupilDiameter(curSignalSection));
                    
                    % Calcualte other metrics:
                    statsTable.([dataNamePrefix ...
                        'SmoothSig_sampleCount'])(segmentIndx) ...
                        = sum(curSignalSection);
                    statsTable.([dataNamePrefix ...
                        'SmoothSig_missingDataPercent'])(segmentIndx) ...
                        = 100*...
                        sum(isnan(...
                        obj.signal.pupilDiameter(curSignalSection)))...
                        / statsTable.([dataNamePrefix ...
                        'SmoothSig_sampleCount'])(segmentIndx);
                    
                end
                
                %----------------------------------------------------------
                
                % Get segment indexes of valid samples:
                curSamplesSection = ...
                    (obj.samples.t_ms./1000>=segmentStart(segmentIndx))...
                    &(obj.samples.t_ms./1000<segmentEnd(segmentIndx));
                
                if sum(curSamplesSection)>0
                    
                    % Analyze valid samples:
                    statsTable.([dataNamePrefix ...
                        'ValidSamples_meanDiam'])(segmentIndx) ...
                        = nanmean(obj.samples.pupilDiameter(curSamplesSection));
                    statsTable.([dataNamePrefix ...
                        'ValidSamples_minDiam'])(segmentIndx) ...
                        = nanmin(obj.samples.pupilDiameter(curSamplesSection));
                    statsTable.([dataNamePrefix ...
                        'ValidSamples_maxDiam'])(segmentIndx) ...
                        = nanmax(obj.samples.pupilDiameter(curSamplesSection));
                    
                    % Calcualte other metrics:
                    statsTable.([dataNamePrefix ...
                        'ValidSamples_validPercent'])(segmentIndx) ...
                        = obj.validFraction*100;
                    statsTable.([dataNamePrefix ...
                        'ValidSamples_sampleCount'])(segmentIndx) ...
                        = sum(curSamplesSection);
                end
                
                %----------------------------------------------------------
                
            end
            
            
        end
    end
    
    
    %% Static Methods:
    
    methods (Static)
        
        %==================================================================
        function settingsOut = getDefaultSettings()
            % getDefaultSettings Returns the standard settings.
            %
            %--------------------------------------------------------------
            
            % The upsampling frequency [Hz] used to generate the smooth
            % signal:
            settingsOut.interp_upsamplingFreq     = 1000;
            
            % Calculate the low pass filter specs using the cutoff
            % frequency [Hz], filter order, and the upsample frequency
            % specified above:
            LpFilt_cutoffFreq         = 4;
            LpFilt_order              = 4;
            [settingsOut.LpFilt_B,settingsOut.LpFilt_A] ...
                = butter(LpFilt_order,2*LpFilt_cutoffFreq...
                /settingsOut.interp_upsamplingFreq );
            
            % Maximum gap [ms] in the used raw samples to interpolate over
            % (section that were interpolated over larger distances will be
            % set to missing; i.e. NaN):
            settingsOut.interp_maxGap             = 250;
            
        end
        
    end
end

