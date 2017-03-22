loadByDialogs = true;

if loadByDialogs
    [filename, pathname] = uigetfile('*.csv','Load emitter csv...');
    if filename==0
        error('You need an emitter csv!');
    end
    emitter_csv = fullfile(pathname,filename);
    
    [filename, pathname] = uigetfile('*.csv','Load algorithm csv...');
    if filename==0
        error('You need an algorithm csv!');
    end
    algorithm_csv = fullfile(pathname,filename);
else
    emitter_csv = 'C:\\Users\\stefko\\Desktop\\emitters.csv';
    algorithm_csv = 'C:\\Users\\stefko\\Desktop\\algorithms.csv';
end

emitter_data = csvread(emitter_csv,2,0);
algorithm_data = csvread(algorithm_csv,2,0);

algorithm_data(:,1) = emitter_data(:,2);

plot(emitter_data(:,1),algorithm_data)