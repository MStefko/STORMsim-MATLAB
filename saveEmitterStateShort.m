function success = saveEmitterStateShort( stack )
%saveEmitterStateShort Exports the synopsis of emitter state in each 
%   frame to a .csv file
%
%Inputs:   
% stack [struct]
%   - emitter_state     Boolean array of emitter states 
%                       [Nemitters x frames]
%
%Outputs:
% success               0 if write was successful, -1 if not

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
success = -1
[filename, pathname] = uiputfile('*.csv','Save short emitter .csv file to...');
if filename==0
    return
end
csv_filename = strcat(pathname,filename);
file = fopen(csv_filename,'w');
fprintf(file, '#Fluorophore states short (matlab-generated)\n');
fprintf(file, '#Frame id, no. of emitters\n')
fclose(file);
data = zeros(size(stack.emitter_state,2),2);

% we need to sum along columns to get total number of on emitters
on_emitters = sum(stack.emitter_state);
data(:,2) = on_emitters'; % mind the apostrophe for transposition
data(:,1) = [1:size(stack.emitter_state,2)];
dlmwrite(csv_filename, data,'-append');

end
