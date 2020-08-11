tic;
load rt


occnum = 1;
sampletime = 5; %min
duration1min = 60*24*60; %sec
startnum = 1000; %with timestep
iodelay = 1;
codelay = 1;
%Tin : 1, Gas : 3, delT : 12
dependentvar_index = 1; 
indepedentvar_index = 1;
%Lrg : 1, arx : 2, armax : 3, nlarx : 4
modeling_index = 3;
na = 5;
nb = 5;
nc = 5;


PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
    iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
    na, nb, nc];


mdl = PredictionModel(rt, PredictionModelParameters);
toc;

%%
tic;
parfor iodelay = 1:100
    
PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
    iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
    na, nb, nc];


mdl = PredictionModel(rt, PredictionModelParameters);
end
toc;

tic;
for iodelay = 1:100
    
PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
    iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
    na, nb, nc];


mdl = PredictionModel(rt, PredictionModelParameters);
end
toc;