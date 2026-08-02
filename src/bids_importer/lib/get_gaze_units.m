function units = get_gaze_units(m, coordField, chanLabel)
units = "";

if isfield(m, 'SampleCoordinateUnits') && ~isempty(m.SampleCoordinateUnits)
    units = m.SampleCoordinateUnits;
    return
end

if isfield(m, coordField) && isfield(m.(coordField), 'Units') && ~isempty(m.(coordField).Units)
    units = m.(coordField).Units;
    return
end

warning('ID:missing_units', 'Units could not be determined for %s channel.', chanLabel);
end
