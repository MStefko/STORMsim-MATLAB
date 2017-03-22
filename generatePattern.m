function [ Optics, Cam, Fluo, Grid ] = generatePattern(genType, Optics, Cam, Fluo, Grid )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

% Copyright © 2017 Laboratory of Experimental Biophysics,
% École Polytechnique Fédérale de Lausanne,
% Author: Marcel Stefko
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
type = 'number';
def = double(Fluo.number);
[pattern,Fluo.emitters,nPulses,dPulses] = emitterGenRandom(def,type,Grid,Cam,Optics,genType);

Fluo.number=nPulses;
Fluo.density=dPulses;

% Image the pattern
Optics.object = pattern;

end

