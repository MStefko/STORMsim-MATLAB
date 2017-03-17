function [x,y,nPulses,dPulses,sizePattern] = templateDistribution(def,Grid,genType,pixel_area,offset)
%Generates randomly localized emitters within a given spatial distribution
%
%Inputs:
% def       can either be
%               dPulses: density of emitters [#/um^2], number of points per
%               area
%               nPulses: number of emitters [#]
% Grid       parameters of the sampling grid [struct]
% gentype    type of the spatial distribution of emitters [string]
% offset 	 x and y distance away from the center pixel [nPulses x 2]
% pixel_area sample area in um^2 imaged by the system corresponding to a single camera pixel 
%
%Outputs:
% x       x-axis position of each emitter
% y       y-axis position of each emitter
% nPulses number of emitters in a single structure
% dPulses density of emitters in a single structure [1/um2]
% sizePattern    size of the image

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

if nargin < 5
    offset = [0,0];
end
f = Grid.template_size;
sizePattern = Grid.sy;
if strcmp(genType,'random')
   sample_area = Grid.sx*Grid.sy*pixel_area; % in [um^2]
    if def < 0 % def is the density of pulses
        dPulses = -def;
        nPulses = round(dPulses* sample_area); 
    else % def is the number of pulses
        dPulses = def/sample_area;
        nPulses = def;
    end
    clear sample_area;
        
    if nPulses == 2
        x = [round(Grid.sy/2);round(Grid.sy/2)];
        y = [-offset + round(Grid.sx/2);offset + round(Grid.sx/2)];
        %emitters_position = [round(Grid.sy/2),-shift + round(Grid.sx/2);round(Grid.sy/2),shift + round(Grid.sx/2)];
    else
        x = 2 + (Grid.sy - 3)*rand(nPulses,1);
        y = 2 + (Grid.sx - 3)*rand(nPulses,1);
        %emitters_position = 2 + [(Grid.sy - 3)*rand(nPulses,1),(Grid.sx - 3)*rand(nPulses,1)];
    end

elseif strcmp(genType,'circular')
    % Radius min and max
    Rmin = 0;Rmax = round(Grid.sx/f);
    % Angle min and max
    a_min = 0;a_max = 2*pi;
    
    sample_area = pi*((Rmax)^2-(Rmin)^2)*pixel_area; % in [um^2]
    if def < 0 % def is the density of pulses
        dPulses = -def;
        nPulses = round(dPulses * sample_area);
    else % def is the number of pulses
        dPulses = def/sample_area;
        nPulses = def;
    end
    clear sample_area;
    
    % radius
    r = sqrt(rand(1,nPulses)*(Rmax^2-Rmin^2)+Rmin^2);
    % angle
    theta = a_min + rand(1,nPulses)*(a_max-a_min);
    % emitter positions
    x = offset(1) + round(Grid.sy/2) + r.*cos(theta);x=x';
    y = offset(2) + round(Grid.sx/2) + r.*sin(theta);y=y';
elseif strcmp(genType,'annular')
    % Radius min and max
    Rmin = round(Grid.sx/f)-round(Grid.sx/(2*f));Rmax = round(Grid.sx/f);
    % Angle min and max
    a_min = 0;a_max = 2*pi;
    
    sample_area = pi*((Rmax)^2-(Rmin)^2)*pixel_area; % in [um^2]
    if def < 0 % def is the density of pulses
        dPulses = -def;
        nPulses = round(dPulses * sample_area); clear sample_area;
    else % def is the number of pulses
        dPulses = def/sample_area;
        nPulses = def;
    end
    clear sample_area;
    
    % radius
    r = sqrt(rand(1,nPulses)*(Rmax^2-Rmin^2)+Rmin^2);
    % angle
    theta = a_min + rand(1,nPulses)*(a_max-a_min);
    % emitter positions
    x = offset(1) + round(Grid.sy/2) + r.*cos(theta);x=x';
    y = offset(2) + round(Grid.sx/2) + r.*sin(theta);y=y';    
elseif strcmp(genType,'segment')
    % Segment at (0,0) and unrotated
    L = round(Grid.sx/f)-1;
    W = 1;%round(Grid.sy/(68*f));
    
    sample_area = L*W*pixel_area; % in [um^2]
    if def < 0 % def is the density of pulses
        dPulses = -def;
        nPulses = round(dPulses * sample_area); clear sample_area;
    else % def is the number of pulses
        dPulses = def/sample_area;
        nPulses = def;
    end
    clear sample_area;
    
    v = [W*(2*rand(nPulses,1)-1), L*(2*rand(nPulses,1)-1)];
    
    % Angles
    theta = 2*pi*rand;
    cot = cos(theta);
    sit = sin(theta);

    % compute rotated coordinates
    x = cot * v(:,1) - sit * v(:,2);x = offset(1) + round(Grid.sy/2) + x;
    y = sit * v(:,1) + cot * v(:,2);y = offset(2) + round(Grid.sx/2) + y;
elseif strcmp(genType,'siemens star')
    % offset=nCycles
    nCycles=offset;
    x0 = linspace(-1,1,Grid.sy); 
    y0 = linspace(-1,1,Grid.sx);

    % cartesian to polar coordinates
    [X0,Y0] = meshgrid(x0,y0);[THETA0,RHO0]=cart2pol(X0,Y0); clear x0 y0 X0 Y0; 
    % in order to prevent aliasing we might put some center pixels to zero
    g=sin(nCycles*THETA0);g(RHO0<0.025)=0;
    [indx,indy]=find(g>0.75); clear g THETA0 RHO0
    
    sample_area = length(indx)*pixel_area; % in [um^2]
    if def < 0 % def is the density of pulses
        dPulses = -def;
        nPulses = round(dPulses * sample_area);
    else % def is the number of pulses
        dPulses = def/sample_area;
        nPulses = def;
    end
        
    xcart=2*(indx-floor(Grid.sy/2))/Grid.sy;clear indx;
    ycart=2*(indy-floor(Grid.sx/2))/Grid.sx;clear indy;
    radius=sqrt(xcart.^2+ycart.^2); 
    angles=atan2(ycart,xcart); clear xcart ycart;
    
    %figure,polar(angles,radius,'o');
    % Remove angles so that the number of angles can be exactly divided by
    % the number of cycles
    rest=mod(length(angles),nCycles);
    if rest~=0;angles(1:rest)=[];radius(1:rest)=[];end;
    angles = sort(angles);
    %rest = mod(nPulses,nCycles);
    %if rest~=0;nPulses = nPulses - rest;end;
    
    section_pulses=round(nPulses/nCycles);section_size=length(angles)/nCycles;
    nPulses = nCycles*section_pulses;dPulses = nPulses/sample_area; clear sample_area;
    
    x=zeros(1,nPulses);
    y=zeros(1,nPulses);
    
    for N_sec=1:nCycles
         pos=round(1+rand(1,section_pulses)*(section_size-1)+(N_sec-1)*section_size);
         while find(pos==0);pos=round(rand(1,section_pulses)*section_size+(N_sec-1)*section_size);end;
         theta=angles(pos);
         %r=radius(pos);
         r = sqrt(rand(1,section_pulses)*(min(Grid.sx-2,Grid.sy-2)^2-0.075^2)+0.075^2);r=r';
         %emitter positions
         x(1+(N_sec-1)*section_pulses:N_sec*section_pulses)=r.*cos(theta);
         y(1+(N_sec-1)*section_pulses:N_sec*section_pulses)=r.*sin(theta);
         clear r theta;
    end
    x=(x+Grid.sy)/2;y=(y+Grid.sx)/2;
    % figure,scatter(x,y);
else
end

end

