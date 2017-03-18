function stacks=simStacks(frames,Optics,Cam,Fluo,Grid)

%Simulate the acquisition of an image sequence of blinking emitters.
%
%Inputs:
% frames                number of frames of the simulated image sequence
% Optics                parameters of the optical set-up and sample 
%                       distribution [struct]
% Cam                   parameters of the recording camera [struct]
% Fluo                  parameters of the fluorophore and sample 
%                       fluorescent properties [struct]
% Grid                  parameters of the sampling grid [struct]
%
%Outputs:
% stacks             Discrete signal as acquired by the camera 
%                    Image sequence [numel(x) x numel(y) x frames]

% Author: Marcel Stefko
% Copyright © 2017 Laboratory of Experimental Biophysics
% École Polytechnique Fédérale de Lausanne.
% Adapted from SOFIsim. (Author: Arik Girsault 2015).
 
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


% Generating Diffraction-Limited and Noisy Brightness Profiles
grid=simStacksCore(frames,Optics,Cam,Fluo,Grid);

% Discretization: photoelectron conversion, electron multiplication,
% readout and thermal noise
fig = statusbar('Discretization...');
for frame = 1:frames
    stacks(:,:,frame) = uint16(gamrnd(grid(:,:,frame),Cam.quantum_gain) + Cam.readout_noise*(randn(Grid.sy,Grid.sx)) + Cam.thermal_noise*randn(Grid.sy,Grid.sx));
    fig = statusbar(frame/frames,fig);
end
delete(fig);clear grid;

end



