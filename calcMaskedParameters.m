function [ Optics, Cam, Fluo, Grid ] = calcMaskedParameters( Optics, Cam, Fluo, Grid )
%Calculates masked parameters of the Optics/Cam/Fluo/Grid structures.
%   Detailed explanation goes here
% ---- user-masked parameters:

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
Fluo.Ion = Fluo.photons_per_second / Cam.acq_speed; % signal [photons/frame]
Grid.blckSize = 3;
Cam.thermal_noise = Cam.dark_current/Cam.acq_speed; % # of electrons per pixel per frame at ambiant air (+20°C)
Cam.quantum_gain = Cam.quantum_efficiency * Cam.gain; % # of electrons per incoming photon ;
[Optics.psf,Optics.psf_digital,Optics.fwhm,Optics.fwhm_digital] = gaussianPSF(Optics.NA,Optics.magnification,Optics.wavelength,Fluo.radius,Cam.pixel_size); % Point-spread function of the optical system
Optics.frames = Cam.acq_speed * Fluo.duration; % number of frames acquired during the experiment

end

