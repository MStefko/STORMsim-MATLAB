function [ Optics, Cam, Fluo, Grid ] = parseCsvFluorophoreFile( filepath )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fig = statusbar('Parsing .csv...');
optics_header = csvread(filepath,2,0,[2,0,2,2]);
cam_header = csvread(filepath,4,0,[4,0,4,5]);
fluo_header = csvread(filepath,6,0,[6,0,6,7]);
grid_header = csvread(filepath,8,0,[8,0,8,1]);

Optics = struct(); Cam = struct(); Fluo = struct(); Grid = struct();
[Optics.NA, Optics.wavelength, Optics.magnification] = split(optics_header);
[Cam.acq_speed, Cam.readout_noise, Cam.dark_current, Cam.quantum_efficiency, Cam.gain, Cam.pixel_size] = split(cam_header);
[Fluo.number, Fluo.duration, Fluo.Ion, Fluo.background, Fluo.Ton, Fluo.Toff, Fluo.Tbl, Fluo.radius] = split(fluo_header);
[Grid.sx, Grid.sy] = split(grid_header);

[Optics, Cam, Fluo, Grid] = calcMaskedParameters( Optics, Cam, Fluo, Grid);
fig = statusbar(0.2,fig);

pixel_side_length_nm = Cam.pixel_size * 1e9;

raw_data = csvread(filepath,10,0,[10,0,10+Fluo.number-1,2]);
x_raw = raw_data(:,2);
y_raw = raw_data(:,3);
fig = statusbar(0.8,fig);
x = x_raw ./ pixel_side_length_nm;
y = y_raw ./ pixel_side_length_nm;

Fluo.emitters = [x, y];
delete(fig)
end


function varargout = split(x,axis)
% return matrix elements as separate output arguments
% optionally can specify an axis to split along (1-based).
% example: [a1,a2,a3,a4] = split(1:4)
% example: [x,y,z] = split(zeros(10,3),2)
if nargin < 2
    axis = 2; % split along cols by default
end
dims=num2cell(size(x));
dims{axis}=ones([1 dims{axis}]);
    varargout = mat2cell(x,dims{:});
end