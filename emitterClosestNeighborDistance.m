function distances = emitterClosestNeighborDistance( emitter_positions, emitter_states )
%emitterClosestNeighborDistance Calculates closest neighbor distances for
%each emitter in each frame.
%Inputs:
% emitter_positions:     x,y position of each emitter [Nemitters x 2]
% emitter_states:        on/off state of each emitter in each frame
%                        [Nemitters x frames]
%
%Outputs:
% distances:             distance to closest on neighbor if it is on,
%                        otherwise 0 [Nemitters x frames]

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

fig = statusbar('Closest neighbor calculation...');

% preallocate results array
distances = np.zeros(size(emitter_states));
Nemitters, frames = size(emitter_positions);
% each frame is independent of others
for f=1:frames
    fig = statusbar(f/frames,fig);
    % iterate over each emitter in this frame
    for k=1:Nemitters
        % if it is turned off, we want result to be 0, so we skip it
        if not(emitter_states(k,f))
            continue
        end
        % get its position in space
        v = emitter_positions(k,:);
        % arbitrary high value
        min_dist2 = 100000000;
        % iterate over all other emitters
        for m=1:Nemitters
            % if it is off, skip it
            if not(emitter_states(m,f))
                continue
            end
            % if it is the same, skip it
            if k==m
                continue
            end
            
            % calculate distance and compare it to current minimum
            V = (v - emitter_positions(m,:));
            dist2 = V * V';
            if dist2<min_dist2
                min_dist2 = dist2;
            end
        end
        % assign the calculated minimal distance to that emitter for this
        % frame
        distances(k,f) = sqrt(min_dist2);
    end
end
delete(fig);

end

