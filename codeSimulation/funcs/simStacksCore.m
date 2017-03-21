function [grid, emitter_state]=simStacksCore(frames,Optics,Cam,Fluo,Grid)
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
emitter_brightness = zeros(Nemitters,frames);
emitter_state = false(Nemitters,frames);

% Generating brightness
fig = statusbar('Brightness...');
for k=1:Nemitters
    fig = statusbar(k/Nemitters,fig);
    [emitter_brightness(k,:), emitter_state(k,:)] = brightness_marcel2(Fluo.Ion,Fluo.Ton,Fluo.Toff,Fluo.Tbl,frames);
    %plot([1:frames], emitter_brightness(k,:), [1:frames] + 0.5, 0.5*Fluo.Ion*emitter_state, 'xr');
    %pause;
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

function [photons, state_bool] = brightness_marcel2(Ion,Ton,Toff,Tbl,frames)
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
% photons      intensity trace of an emitter [photons]
% state_bool   was the emitter on at each frame? [bool array]

% We assume that the time of stay in both on and off states follows an
% exponential distribution (similar to atom decay - the probability of
% switching from one state to another in the next time interval is 
% independent of elapsed time). This means that mean lifetimes Ton and 
% Toff serve as time constants in these distributions. Both states can 
% as well decay into the bleached state. 

% First we compute
% if the fluorophore will bleach before end of measurement.
time_of_bleach = exprnd(Tbl);
% this will be true of we need to care about bleaching
does_bleach = time_of_bleach < frames;

% determine if we start in an on-state or off-state
current_state = rand < Ton/(Ton+Toff);
current_time = 0;
current_frame = 1;
photons = zeros(frames,1); % preallocate photon array
state_bool = false(frames,1);
while current_frame <= frames
    if current_state % if we are on
        state_lifetime = exprnd(Ton);
        if current_frame == frames
            photons(current_frame) = poissrnd(Ion*min([state_lifetime,1]));
            break;
        end
        % now we bring current_time up to a whole number
        diff = ceil(current_time) - current_time;
        if (diff>0)
            if (diff <= state_lifetime) && (diff>0)
                state_lifetime = state_lifetime - diff;
                photons(current_frame) = photons(current_frame) + poissrnd(Ion*diff);
                current_time = ceil(current_time);
                current_frame = current_frame + 1;
                if state_lifetime <= 0
                    current_state = false;
                    continue;
                end

            else % we are only within the frame
                photons(current_frame) = photons(current_frame) + poissrnd(Ion*diff);
                current_time = current_time + diff;
                current_state = false;
                continue;
            end
        end
        % now we are sure we are at integer value of current_time
        while (state_lifetime > 1) && (current_frame < frames)
            photons(current_frame) = poissrnd(Ion);
            state_bool(current_frame) = true;
            state_lifetime = state_lifetime - 1;
            current_time = current_time + 1;
            current_frame = current_frame + 1;
        end
        if current_frame == frames
            photons(current_frame) = poissrnd(Ion*min([state_lifetime,1]));
            if (state_lifetime > 0.5)
                state_bool(current_frame) = true;
            end
            break;
        end
        % current_time is integer, state_lifetime is smaller than 1
        state_bool(current_frame) = true;
        photons(current_frame) = poissrnd(Ion*state_lifetime);
        current_time = current_time + state_lifetime;
        current_state = false;
        continue;
    else
        state_lifetime = exprnd(Toff);
        current_time = current_time + state_lifetime;
        current_frame = ceil(current_time);
        current_state = true;
        continue;
    end
end

if does_bleach
    if time_of_bleach < 1
        time_of_bleach = 1;
    end
    photons(floor(time_of_bleach):end) = 0;
    state_bool(floor(time_of_bleach):end) = false;
end

end