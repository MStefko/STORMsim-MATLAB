# STORMsim

MATLAB toolkit for simulating simple STORM datasets. The MATLAB version is no longer under development, for a currently developed Java implementation, see <https://github.com/MStefko/AlgorithmTester>.

## Usage
Simulation parameters are defined in `run.m`, which also runs the simulation.

Simulation outputs are:
  1. `.tif` stack with pixel data.
  2. `.csv` file with simulation parameters and emitter position info.
  3. `.csv` file with emitter state information (number of on-emitters in each frame, and statistics about their distances
  (min, mean, 10-th percentile).
  
## Inner function
In simple terms, the simulation proceeds as follows:
  1. Emitter positions are randomly generated, or loaded from a `.csv` file.
  2. For each emitter, its brightness pattern over time is simulated based on the time constants of 
  off, on, and bleached state transitions.
  3. Image pixel data is generated based on the emitter position and brightness data, taking into
  account various noise sources.
  
## Acknowledgements
STORMsim core was adapted under GPL from SOFIsim,
a package developed by Arik Girsault and Tomas Lukes of Laboratoire 
d'Optique Biomédicale at EPFL. <http://lob.epfl.ch/> 
