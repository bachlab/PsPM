function [lat, lon, lat_range, lon_range] = pspm_compute_visual_angle_core(x_data, y_data, width, height, distance, options)
% pspm_compute_visual_angle computes from gaze data the corresponding
% visual angle (for each data point). The convention used here is that the
% origin of coordinate system for gaze data is at the bottom left corner of
% the screen.
%
% FORMAT:
%       [lat, lon, lat_range, lon_range ] = pspm_compute_visual_angle_core(x_data, y_data, options)
%
% ARGUMENTS:
%       x_data:           X axis data
%       y_data:           y axis data
%       width:            screen width in same units as data
%       height:           screen height in same units as data
%       distance:         screen distance in same units as data
%       options:
%         .interpolate:   Boolean - Interpolate values
%
% RETURN VALUES
%               lat:            the latitude in degrees
%               lon:            the longitude in degrees
%               lat_range:      the latitude range
%               lon_range:      the longitude range
%__________________________________________________________________________
% PsPM 4.0
%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
options = pspm_options(options);
% interpolate channel specific data if required
if options.interpolate
  interpolate_options = struct('extrapolate', 1);
  [ sts_x, gx_d ] = pspm_interpolate(x_data, interpolate_options);
  [ sts_x, gy_d ] = pspm_interpolate(y_data, interpolate_options);
else
  gx_d = x_data;
  gy_d = x_data;
end

% The convention is that the origin of the screen is in the bottom
% left corner, so the following line is not needed a priori, but I
% leave it anyway just in case :
% gy_d = data{gy}.header.range(2)-gy_d;

N = numel(gx_d);
if N~=numel(gy_d)
  warning('ID:invalid_input', 'length of data in gaze_x and gaze_y is not the same');
  return;
end;

% move (0,0) into center of the screen
gx_d = gx_d - width/2;
gy_d = gy_d - height/2;

% compute visual angle for gaze_x and gaze_y data:
% 1) x axis in cartesian coordinates
s_x = gx_d;
% 2) y axis in cartesian coordinates, actually the distance from participant to the screen
s_y = distance * ones(numel(gx_d),1);
% 3) z axis in spherical coordinates, actually the y axis of the screen
s_z = gy_d;
% 4) convert cartesian to spherical coordinates in radians,
%    where azimuth = longitude, elevation = latitude
%    the center of spherical coordinates are the eyes of the subject
[azimuth, elevation, ~]= cart2sph(s_x,s_y,s_z);
% 5) convert radians into degrees
lat = rad2deg(elevation);
lon = rad2deg(azimuth);

% compute visual angle for the range (same procedure)
r_x = [-width/2,width/2,0,0]';
r_y = distance * ones(numel(r_x),1);
r_z = [0,0,-height/2,height/2]';
[x_range_sp, y_range_sp,~]= cart2sph(r_x,r_y,r_z);

x_range_sp = rad2deg(x_range_sp);
y_range_sp = rad2deg(y_range_sp);

lon_range = [x_range_sp(1),x_range_sp(2)];
lat_range = [y_range_sp(3),y_range_sp(4)];

