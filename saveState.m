function success = saveState( Optics, Cam, Fluo, Grid )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
success = -1
[filename, pathname] = uiputfile('*.csv','Save .csv file to...');
if filename==0
    return
end
csv_filename = strcat(pathname,filename);
success = saveFluorophoresToCsv(csv_filename,Optics,Cam,Fluo,Grid);
end

