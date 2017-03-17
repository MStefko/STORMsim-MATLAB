function success = saveFluorophoresToCsv(filepath, Optics, Cam, Fluo, Grid)
%saveFluorophoresToCsv Exports current fluorophore distribution to a .csv
%   file
%
%Inputs:   
% filepath              Path for .csv to write to [string]
% Optics                parameters of the optical set-up and sample 
%                       distribution [struct]
% Cam                   parameters of the recording camera [struct]
% Fluo                  parameters of the fluorophore and sample 
%                       fluorescent properties [struct]
% Grid                  parameters of the sampling grid [struct]
%
%Outputs:
% success               0 if write was successful, -1 if not
success = -1;

emitter_position = Fluo.emitters; % x and y positions of each emitters
N_emitters = size(emitter_position,1);
pixel_side_length_m = Cam.pixel_size;
pixel_side_length_nm = pixel_side_length_m * 1e9;
field_side_length_nm = pixel_side_length_nm * Grid.sx;


file = fopen(filepath,'w');
fprintf(file,'#Fluorophore localizations (MATLAB-generated)\n');
fprintf(file,'#Field size x [nm], field size y [nm], no. of fluorophores [-]\n');
fprintf(file,'%d,%d,%d\n',field_side_length_nm,field_side_length_nm,N_emitters);

x_nm = emitter_position(:,1) * pixel_side_length_nm;
y_nm = emitter_position(:,2) * pixel_side_length_nm;

fig = statusbar('Saving .csv data...');
fprintf(file,'#id[-],x[nm],y[nm]\n');
for i=[1:N_emitters]
    fprintf(file,'%d,%f,%f\n',i,x_nm(i),y_nm(i));
    fig = statusbar(i/N_emitters,fig);
end
delete(fig)
success = fclose(file);



