function grid=simStacksCore(frames,Optics,Cam,Fluo,Grid)
%Simulate an image sequence of blinking emitters.
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
% grid               Discrete signal prior to camera acquisition
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

s_xy = Optics.fwhm_digital/2.3548;

r = 3*s_xy;

emitter_position = Fluo.emitters; % x and y positions of each emitters
Nemitters = size(emitter_position,1);
emitter_brightness = zeros(size(emitter_position,1),frames);

% Generating brightness
fig = statusbar('Brightness...');
for k=1:Nemitters
    fig = statusbar(k/Nemitters,fig);
    emitter_brightness(k,:) = brightness(Fluo.Ion,Fluo.Ton,Fluo.Toff,Fluo.Tbl,frames);
end

% Discrete Signal
[gridX,gridY] = meshgrid(1:Grid.sx,1:Grid.sy); % pixel number within the camera
grid = zeros(Grid.sy,Grid.sx,frames); % pixel values of the camera for all frames


% Diffraction
fig = statusbar('Diffraction...',fig);
for m=1:Nemitters
    fig = statusbar(m/Nemitters,fig);
    % Discrete Grid
    [x,y]=ind2sub(size(grid),find((gridY - emitter_position(m,1)).^2 + (gridX - emitter_position(m,2)).^2 <=  r^2 == 1));
    for k=1:length(x)
        grid(x(k),y(k),:)= squeeze(grid(x(k),y(k),:)).' + 0.25*emitter_brightness(m,:)*...
                         (erf((x(k)-emitter_position(m,1)+0.5)/(sqrt(2)*s_xy)) - erf((x(k)-emitter_position(m,1)-0.5)/(sqrt(2)*s_xy))).*...
                         (erf((y(k)-emitter_position(m,2)+0.5)/(sqrt(2)*s_xy)) - erf((y(k)-emitter_position(m,2)-0.5)/(sqrt(2)*s_xy)));
    end
    clear x y;
end

% add poisson noise
fig = statusbar('Poisson Noise...',fig);
for frame = 1:frames
    fig = statusbar(frame/frames,fig);
    grid(:,:,frame) = imnoise(uint16(max(0,grid(:,:,frame)-Fluo.background)+Fluo.background),'poisson');
end
delete(fig);

end

function photons=brightness(Ion,Ton,Toff,Tbl,frames)
%Simulate the intensity trace of an emitter (photons per frame).
%
%Inputs:
% Ion       maximum signal per emitter per frame [photons]
% Ton       average duration of the on-state [frames]
% Toff      average duration of the off-state [frames]
% Tbl       bleaching lifetime [frames]
% frames    number of frames comprising the image sequence [frames]
%
%Outputs:
% photons   intensity trace of an emitter [photons]

cycle=Ton + Toff; % length of a cycle: for a fluorophore to reach the onstate and in the offstate 
cycles=10 + ceil(frames/cycle); % number of cycles in the entire experiment (the +10 creates ten cycles in addition to avoid problems near t~0)
times=[-Toff*log(rand(1,cycles));-Ton*log(rand(1,cycles))]; % probability of being in one state is between 0 and 1 (normal distribution)
times(1)=times(1) - rand*(sum(times(1:10))); % for t~0, the probability is one. Therefore, this makes the fluorophore start in the state Toff (in theory)
% otherwise the initial values are far to high
times=cumsum(times(:)); % cumulative sums of times
% --- redo the exact same steps if the times is not as long as frames
while times(end) < frames
   cycles=ceil(2*(frames - times(end))/cycle);
   cycles=[-Toff*log(rand(1,cycles));-Ton*log(rand(1,cycles))];
   cycles(1)=cycles(1) + times(end);
%    temp = elongate(times,cycles(:));clear times;
%    times = temp; clear temp;
   times=[times;cumsum(cycles(:))];
end

times=times.';
% times contains successively periods of activation and periods of off
% (hence the blinking) both described by a normal distribution. Since Toff
% > Ton, then the fluorophore is longer in the off state.

Ton=times(2:2:end) - times(1:2:end); % times(2,:) when size(times) was 2x60 (line 46)
Tbl=cumsum(Ton) + Tbl*log(rand); % the bleaching state is another state as 
% Ton and Toff. Here we cumulate only the times of Ton since it is the one
% that contributes to approach the bleaching state. Tbl follows the same
% distribution as the other two states (hence the log).
n=find(Tbl > 0); % did Ton reached Tbl ? 
if any(n)
   Ton(n(2:end))=0; % the fluorophore is bleached (no Ton left in the signal)
   n=n(1);
   Ton(n)=Ton(n) - Tbl(n);
   times(2*n)=times(2*n) - Tbl(n); % the last "times" is put to 0
end
photons=[zeros(size(Ton));Ion*Ton];clear Ion; clear Ton; clear Tbl;
photons=cumsum(photons(:)); % one point over two has no photons, this is 
% the period in the off state. All others have photons for successive
% duratoins of Ton.
photons=diff(interp1(times,photons,0:frames,'linear',0));clear times;
% times' unit is in number of frames. So here, we are actually looking for
% the number of photons in specific frames (which can in principle not be
% sampled in "times" thus the interpolation). We are computing photons(times)
% at times = 0:frames. Toff > Ton --> thus big steps in times (or large
% periods of frames) corresponds to odd samples (sample point that are
% defined by Toff), and small steps in times (or small periods of frames)
% corresponds to even samples (sample point that are defined by Ton).
% Therefore when looking for the number of photons in a arbitrary frame, it
% is likely the number of fluorophore is small (since there are much more
% frames "stay off" then frames "go on").
end
