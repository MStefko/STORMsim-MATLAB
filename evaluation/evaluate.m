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
    emitter_csv = 'C:\\Users\\stefko\\Documents\\test3\\emitter_state.csv';
    algorithm_csv = 'C:\\Users\\stefko\\Documents\\test3\\output_algorithms.csv';
end
emitter_csv
algorithm_csv

alg_file = fopen(algorithm_csv,'r');
fgetl(alg_file); % discard first line
header_algorithm_settings = fgetl(alg_file)
fgetl(alg_file); % discard third line
header_algorithms = fgetl(alg_file);

header = strsplit(header_algorithms,',');
header{1} = 'real\_count';

emitter_data = csvread(emitter_csv,2,0);
algorithm_data = csvread(algorithm_csv,4,0);

algorithm_data(:,1) = emitter_data(:,2);
normalized_data = normalizeColumnsByMean(algorithm_data);

movmean_data = movmean(normalized_data, 25);
plot(emitter_data(:,1),movmean_data)
legend(header)