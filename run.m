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
        Fluo.number = 150; % number of fluorophores [-]
        Fluo.duration = 6; % acquisition time [s]
        Fluo.Ion = 400; % signal [photons]
        Fluo.background = 2; % background [photons]
        Fluo.Ton = 20 * 1e-3; % on-time ms ->[s]
        Fluo.Toff = 80 * 1e-3; % off-time ms -> [s]
        Fluo.Tbl = 80; % bleaching time [s]
        Fluo.radius = sqrt(64) * 1e-9; % square root of absorption cross-section nm -> [m]

        Grid = struct();
        Grid.sy = 100; % [pixels]
        Grid.sx = 100; % [pixels]
        
        [Optics, Cam, Fluo, Grid] = calcMaskedParameters( Optics, Cam, Fluo, Grid);
        [Optics, Cam, Fluo, Grid] = generatePattern('random',Optics, Cam, Fluo, Grid);
end



choice = questdlg('Generate image stack now?','Generate stack','Yes','No','No');
if strcmp(choice,'Yes')
    stacks = generateTimeTraces(Optics, Cam, Fluo, Grid);
    doSave = questdlg('Save .tif image stack now?','Save stack','Yes','No','No');
    if strcmp(doSave,'Yes')
        saveTiff(stacks.discrete, Optics, Cam, Fluo, Grid);
    end
end