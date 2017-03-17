function [ Optics, Cam, Fluo, Grid ] = calcMaskedParameters( Optics, Cam, Fluo, Grid )
%Calculates masked parameters of the Optics/Cam/Fluo/Grid structures.
%   Detailed explanation goes here
% ---- user-masked parameters:
Grid.blckSize = 3;
Cam.thermal_noise = Cam.dark_current/Cam.acq_speed; % # of electrons per pixel per frame at ambiant air (+20°C)
Cam.quantum_gain = Cam.quantum_efficiency * Cam.gain; % # of electrons per incoming photon ;
[Optics.psf,Optics.psf_digital,Optics.fwhm,Optics.fwhm_digital] = gaussianPSF(Optics.NA,Optics.magnification,Optics.wavelength,Fluo.radius,Cam.pixel_size); % Point-spread function of the optical system
[pattern,Fluo.emitters] = emitterGen(Fluo.number,'number',Grid,Cam,Optics);
Optics.object = pattern; clear pattern;
Optics.frames = Cam.acq_speed * Fluo.duration; % number of frames acquired during the experiment
% ---- end user-masked parameters;

end

