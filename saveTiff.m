function success = saveTiff(stacks, Optics, Cam, Fluo, Grid)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
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

