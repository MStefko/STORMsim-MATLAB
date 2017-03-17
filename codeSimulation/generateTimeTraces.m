function stacks = generateTimeTraces(Optics, Cam, Fluo, Grid)
%Generate the image sequence of blinking emitters.
%
%Inputs:
% hRoot                 handles to SOFIsim interfaces [Figure] 
% intensity_peak_mode   boolean specifying whether the simulation is based 
%                       on the intensity peak and S/B or on the signal per 
%                       frame and background
% tutorial              boolean specifying whether analog time traces 
%                       should be computed or not

% Copyright © 2015 Arik Girsault 
% École Polytechnique Fédérale de Lausanne,
% Laboratoire d'Optique Biomédicale, BM 5.142, Station 17, 1015 Lausanne, Switzerland.
% arik.girsault@epfl.ch, tomas.lukes@epfl.ch
% http://lob.epfl.ch/
 
% This file is part of SOFIsim.
%
% SOFIsim is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% SOFIsim is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with SOFIsim.  If not, see <http://www.gnu.org/licenses/>.

% check whether the simulation is based on the intensity peak and S/B 
% or on the signal per frame and background

% conversion of time unit in frames
Fluo.Ton = Fluo.Ton * Cam.acq_speed; 
Fluo.Toff = Fluo.Toff * Cam.acq_speed;
Fluo.Tbl = Fluo.Tbl * Cam.acq_speed;

% time Traces of the digital signal recorded at the camera
stacks = simStacks(Optics.frames,Optics,Cam,Fluo,Grid);
end

