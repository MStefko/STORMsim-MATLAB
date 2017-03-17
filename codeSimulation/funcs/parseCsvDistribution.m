function [x,y,nPulses,dPulses,sizePattern] = parseCsvDistribution( filepath, pixel_area_um2)
%parseCsvDistribution Load up fluorophore localizations from a .csv file.
%Csv file has format:
%
%  #Fluorophore localizations
%  #Field size x [nm], field size y [nm], no. of fluorophores [-]
%  100000,100000,10
%  #id[-],x[nm],y[nm]
%  1,10.0,15.0
%  2,3546.9,12315.3568
%  ...
%  10,3584684.3,156EOF
%
%Outputs:
% x       x-axis position of each emitter
% y       y-axis position of each emitter
% nPulses number of emitters in a single structure
% dPulses density of emitters in a single structure [1/um2]
% sizePattern    size of the image

% read header
fig = statusbar('Parsing .csv...');
header = csvread(filepath,2,0,[2,0,2,2]);
size_x_nm = header(1);
size_y_nm = header(2);
nPulses = header(3);
if size_x_nm~=size_y_nm
    error('Field is not square! We can only work with square fields of view for now.')
end
pixel_side_length_nm = sqrt(pixel_area_um2)*1000;
sizePattern = round(size_x_nm ./ pixel_side_length_nm);
fig = statusbar(0.2,fig);
% read body of csv
raw_data = csvread(filepath,4,0,[4,0,4+nPulses-1,2]);
x_raw = raw_data(:,2);
y_raw = raw_data(:,3);
fig = statusbar(0.8,fig);
x = x_raw ./ pixel_side_length_nm;
y = y_raw ./ pixel_side_length_nm;

density_per_nm2 = nPulses ./ (size_x_nm * size_y_nm);
density_per_um2 = density_per_nm2 * 1000000;
dPulses = density_per_um2;
delete(fig)
end

