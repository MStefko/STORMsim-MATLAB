% Author: Marcel Stefko
% Copyright © 2017 Laboratory of Experimental Biophysics,
% École Polytechnique Fédérale de Lausanne,
% marcel.stefko@epfl.ch
 
% This file is part of STORMsim, a software package for simulating 
% fluorescent microscopy data.
%
% Several parts of this package's core were adapted under GPL from SOFIsim,
% a package developed by Arik Girsault and Tomas Lukes of Laboratoire 
% d'Optique Biomédicale at EPFL. <http://lob.epfl.ch/>
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
clear all; clc

dialogs = false;

default_fluorophore_positions_csv_open = 'C:\\Users\\stefko\\Documents\\fluorophore_positions.csv';
default_folder = 'C:\\Users\\stefko\\Documents\\sim5\\';
if 7~=exist(default_folder,'dir')
    mkdir(default_folder);
end
default_tifstack_save = strcat(default_folder,'image_stack.tif');
default_state_csv_save = strcat(default_folder,'sim_state.csv');
default_emitter_csv_save = strcat(default_folder,'emitter_state.csv');

if dialogs
    choice_opencsv = questdlg('Open .csv file or use default settings?','Open file','Open','Default','Default');
    if strcmp(choice_opencsv,'Open')
        [filename, pathname, filterindex] = uigetfile('*.csv','Select the fluorophore .csv file.');
        fluorophore_csv = fullfile(pathname, filename);
    end
    
    [filename, pathname] = uiputfile('*.tif','Save .tif stack to...');
    if filename==0
        return
    end
    tif_filepath = fullfile(pathname,filename);
    
    [filename, pathname] = uiputfile('*.tif','Save simulation state to...');
    if filename==0
        return
    end
    state_csv = fullfile(pathname,filename);
    
    [filename, pathname] = uiputfile('*.tif','Save emitter state to...');
    if filename==0
        return
    end
    emitter_csv = fullfile(pathname,filename);
    
else
    choice_opencsv = 'Default';
    fluorophore_csv = default_fluorophore_positions_csv_open;
    tif_filepath = default_tifstack_save;
    state_csv = default_state_csv_save;
    emitter_csv = default_emitter_csv_save;
end

switch choice_opencsv
    case 'Open'
        [Optics, Cam, Fluo, Grid] = parseCsvFluorophoreFile(fluorophore_csv);
        [Optics, Cam, Fluo, Grid] = calcMaskedParameters( Optics, Cam, Fluo, Grid);
    case 'Default'
        Optics = struct();
        Optics.NA = 1.3; % numerical aperture [-]
        Optics.wavelength = 600 * 1e-9; % wavelength nm -> [m]
        Optics.magnification = 100; % magnification [-]

        Cam = struct();
        Cam.acq_speed = 100; % frames per second [frames/s]
        Cam.readout_noise = 1.6; % RMS value [???]
        Cam.dark_current = 0.06; % [electrons/pixel/s]
        Cam.quantum_efficiency = 0.8; % [-]
        Cam.gain = 6; % [-]
        Cam.pixel_size = 6.45 * 1e-6; % um -> [m]

        Fluo = struct();
        Fluo.photons_per_second = 50000;%4000000; % signal [photons/s]
        Fluo.number = 4*400; % number of fluorophores [-]
        Fluo.duration = 30; % acquisition time [s]
        Fluo.background = 500/100;%50000/100; % background [photons]
        Fluo.Ton = 80 * 1e-3; % on-time ms ->[s]
        Fluo.Toff = 300 * 1e-3; % off-time ms -> [s]
        Fluo.Tbl = 20; % bleaching time [s]
        Fluo.radius = sqrt(64) * 1e-9; % square root of absorption cross-section nm -> [m]

        Grid = struct();
        Grid.sy = 400; % [pixels]
        Grid.sx = 400; % [pixels]
        
        [Optics, Cam, Fluo, Grid] = calcMaskedParameters( Optics, Cam, Fluo, Grid);
        [Optics, Cam, Fluo, Grid] = generatePattern('random',Optics, Cam, Fluo, Grid);
end

stack = generateTimeTraces(Optics, Cam, Fluo, Grid);

options = struct();
options.overwrite = true;
success = saveastiff(stack.pixels,tif_filepath, options);

saveState(Optics,Cam,Fluo,Grid,state_csv)

saveEmitterStateShort(stack,emitter_csv);



