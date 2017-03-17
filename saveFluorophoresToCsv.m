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


file = fopen(filepath,'w');
fprintf(file,'#Fluorophore localizations (MATLAB-generated)\n');

fprintf(file,'#Optics:Numerical aperture[-], wavelength [m], magnification[-]\n');
fprintf(file,'%f,%e,%f\n',Optics.NA, Optics.wavelength, Optics.magnification);

fprintf(file,'#Cam:acq speed[frames/s], readout_noise RMS [-], dark_current [el/px/s], quantum_efficiency [-], gain [-], pixel_size[m]\n');
fprintf(file,'%d,%f,%f,%f,%f,%e\n',Cam.acq_speed, Cam.readout_noise, Cam.dark_current, Cam.quantum_efficiency, Cam.gain, Cam.pixel_size);

fprintf(file,'#Fluo: number[-],acq_duration[s],Ion[photons],background[photons],on_time[s],off_time[s],bleaching_time[s],absorption_radius[m]\n');
fprintf(file,'%d,%f,%d,%d,%e,%e,%e,%e\n',Fluo.number, Fluo.duration, Fluo.Ion, Fluo.background, Fluo.Ton, Fluo.Toff, Fluo.Tbl, Fluo.radius);

fprintf(file,'#Grid:Field size x [pixels], field size y [pixels]\n');
fprintf(file,'%d,%d\n',Grid.sx, Grid.sy);

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



