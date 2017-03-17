function [ Optics, Cam, Fluo, Grid ] = generatePattern(genType, Optics, Cam, Fluo, Grid )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
type = 'number'
def = double(Fluo.number)
[pattern,Fluo.emitters,nPulses,dPulses] = emitterGenRandom(def,type,Grid,Cam,Optics,genType);

Fluo.number=nPulses;
Fluo.density=dPulses;

% Image the pattern
Optics.object = pattern;

end

