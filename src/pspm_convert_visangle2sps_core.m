function arclen = pspm_convert_visangle2sps_core(lat, lon)
% ● Description
% ● Format
%   arclen = pspm_convert_visangle2sps_core(lat, lon)
% ● Arguments
%   lat:
%   lon:
% ● Version History
%   Introduced in TBA.
% ● Written By
%   TBA.
% ● Maintained By
%   2022 Teddy Chao (UCL)

if sum(isnan(lon)) > 0 || sum(isnan(lat)) > 0
  warning('ID:invalid_input', ...
    'cannot calculate sps from data with NaN values, check gaze degree data for NaNs');
  return;
end
% compare if length are the same
if numel(lon) ~=numel(lat)
  warning('ID:invalid_input', 'length of data in gaze_x and gaze_y is not the same');
  return;
end
% convert lon and lat into radians
lon = deg2rad(lon);
lat = deg2rad(lat);
% compute distances
arclen = zeros(length(lat),1);
% Haversine
lat_diff = (lat(2:end) - lat(1:end - 1)) / 2;
lon_diff = (lon(2:end) - lon(1:end - 1)) / 2;
theta = sin(lat_diff).^2 + cos(lat(1:end - 1)) .* cos(lat(2:end)) .* sin(lon_diff).^2;
arclen(2:end) = 2 * atan2(sqrt(theta),sqrt(1 - theta));