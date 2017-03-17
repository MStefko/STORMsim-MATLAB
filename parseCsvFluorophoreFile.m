function [ Optics, Cam, Fluo, Grid ] = parseCsvFluorophoreFile( filepath )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Copyright © 2017 Laboratory of Experimental Biophysics,
% École Polytechnique Fédérale de Lausanne,
% Author: Marcel Stefko
% marcel.stefko@epfl.ch
 
% This file is part of STORMsim, a software package for simulating 
% fluorescent microscopy data.
%
% Several parts of this package's core were adapted under GPL from SOFIsim,
% a package developed by Arik Girsault and Tomas Lukes of Laboratoire 
% d'Optique Biomédicale at EPFL. <http://lob.epfl.ch/> Individual file 
% authorship is defined in file headers. 
%
% STORMsim is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% STORMsim is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with STORMsim.  If not, see <http://www.gnu.org/licenses/>.
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