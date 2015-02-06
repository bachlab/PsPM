function [sts, import, sourceinfo] = scr_get_labchartmat_in(datafile, import)
% scr_get_labchartmat_ext is the main function for import of LabChart
% (ADInstruments) files, exported into matlab using built-in export feature.
% For the online LabChart see scr_labchartmat_ext
% FORMAT: [sts, import, sourceinfo] = scr_get_labchartmat_in(datafile, import);
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_get_labchartmat_in.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% ------------------------------------------------------------------------
% NOTE this info is inherited from the old labchart export code but I
% assume it's still valid
%
% Tue Jun 08, 2010 12:25 am from
% http://www.adinstruments.com/forum/viewtopic.php?f=7&t=35&p=79#p79
% Export MATLAB writes the comment timestamps using the overall "tick rate".
% The tick rate corresponds to the highest sample rate. If all channels are
% at the same sample rate then that's the tick rate. However if you had
% three channels recorded at 1kHz, 2kHz and 500Hz, then the tick rate would
% be 2kHz and the comment positions would be at 2kHz ticks.
% John Enlow, Windows Development Manager, ADInstruments, New Zealand
% -------------------------------------------------------------------------
% NOTE
% apparently (according to sample files provided by Jessica Golle, U Bern,
% when multiple blocks are recorded, markers are counted wrt intra-block
% time (26.06.2013)
% -------------------------------------------------------------------------

% initialise 
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
sourceinfo = []; sts = -1;

% load & check data
% -------------------------------------------------------------------------
labchart = load(datafile);
blkno = numel(labchart.blocktimes);

% extract invidual channels
% -------------------------------------------------------------------------
% prepare import jobs ---
oldimport = import;
clear import

% loop through data blocks ---
for blk = 1:blkno
    import{blk} = oldimport;
    % loop through import jobs ---
    for k = 1:numel(import{blk}) 
        
        if strcmpi(import{blk}{k}.type, 'marker')
            import{blk}{k}.sr = 1./labchart.tickrate(blk);
            import{blk}{k}.marker = 'timestamps';
            markerindex = labchart.com(:, 2) == blk;
            markertype = cellstr(labchart.comtext);
            import{blk}{k}.data = labchart.com(markerindex, 3);
            import{blk}{k}.markerinfo.name = markertype(labchart.com(markerindex, 5));
            import{blk}{k}.markerinfo.value = labchart.com(markerindex, 5);
        else
            % define channel number ---
            if import{blk}{k}.channel > 0
                chan = import{blk}{k}.channel;
            else
                chan = scr_find_channel(cellstr(labchart.titles), import{blk}{k}.type);
                if chan < 1, return; end;
            end;
            
            if chan > numel(cellstr(labchart.titles)), warning('ID:channel_not_contained_in_file', 'Channel %02.0f not contained in file %s.\n', chan, datafile); return; end;
            
            sourceinfo{blk}.chan{k, 1} = sprintf('Channel %02.0f: %s', chan, labchart.titles(chan, :));
            
            % get data (a simple vector)
            import{blk}{k}.data = [zeros(1, labchart.firstsampleoffset(chan, blk)), ...
                labchart.data(labchart.datastart(chan, blk):labchart.dataend(chan, blk))];
            % get sample rate
            import{blk}{k}.sr = labchart.samplerate(chan, blk);
        end;
    end;
end;


sts = 1;
return;
