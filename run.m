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
choice = questdlg('Open .csv file or use default settings?','Open file','Open','Default','Default');
switch choice
    case 'Open'
        [filename, pathname, filterindex] = uigetfile('*.csv','Select the fluorophore .csv file.');
        filepath = fullfile(pathname, filename);
        [Optics, Cam, Fluo, Grid] = parseCsvFluorophoreFile(filepath)
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
        Fluo.number = 200; % number of fluorophores [-]
        Fluo.duration = 6; % acquisition time [s]
        Fluo.Ion = 400; % signal [photons]
        Fluo.background = 2; % background [photons]
        Fluo.Ton = 20 * 1e-3; % on-time ms ->[s]
        Fluo.Toff = 80 * 1e-3; % off-time ms -> [s]
        Fluo.Tbl = 80; % bleaching time [s]
        Fluo.radius = sqrt(64) * 1e-9; % square root of absorption cross-section nm -> [m]

        Grid = struct();
        Grid.sy = 200; % [pixels]
        Grid.sx = 200; % [pixels]
        
        [Optics, Cam, Fluo, Grid] = calcMaskedParameters( Optics, Cam, Fluo, Grid);
        [Optics, Cam, Fluo, Grid] = generatePattern('random',Optics, Cam, Fluo, Grid);
end



choice = questdlg('Generate image stack now?','Generate stack','Yes','No','No');
if strcmp(choice,'Yes')
    stacks = generateTimeTraces(Optics, Cam, Fluo, Grid);
    doSave = questdlg('Save .tif image stack now?','Save stack','Yes','No','No');
    if strcmp(doSave,'Yes')
        saveTiff(stacks, Optics, Cam, Fluo, Grid);
    end
end