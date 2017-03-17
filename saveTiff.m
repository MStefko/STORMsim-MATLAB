function success = saveTiff(stacks, Optics, Cam, Fluo, Grid)
%UNTITLED7 Summary of this function goes here
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
% d'Optique Biomédicale at EPFL. <http://lob.epfl.ch/> Individual file 
% authorship is defined in file headers. 
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
success = -1;
[filename, pathname] = uiputfile('*.tif','Save .tif stack to...');
if filename==0
    return
end
tif_filepath = fullfile(pathname,filename);

% T = Tiff(tif_filepath, 'w')

% T.setTag('Photometric',Tiff.Photometric.MinIsBlack);
% T.setTag('Compression',Tiff.Compression.None);
% T.setTag('BitsPerSample',16);
% T.setTag('SamplesPerPixel',1);
% T.setTag('PlanarConfiguration', Tiff.PlanarConfiguration.Chunky);
% T.setTag('ResolutionUnit', Tiff.ResolutionUnit.Centimeter);
% T.setTag('XResolution', 1 ./ (Cam.pixel_size * 100));
% T.setTag('YResolution', 1 ./ (Cam.pixel_size * 100));
% T.setTag('SampleFormat', Tiff.SampleFormat.UInt);
% T.setTag('SubFileType', Tiff.SubFileType.Page);
% T.setTag('ImageWidth', Grid.sx);
% T.setTag('ImageLength', Grid.sy);
% T.setTag('TileLength',32);
% T.setTag('TileWidth',32);
% T.setTag('PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
% T.setTag('ExtraSamples',Tiff.ExtraSamples.Unspecified);

% for i=1:size(stacks,3)
%     T.write(stacks(:,:,i));
% T.close();

options = struct();
options.overwrite = true;

success = saveastiff(stacks,tif_filepath, options)
end

