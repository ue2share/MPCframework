%% Saving Results in table.
tab = array2table(zeros(0, 13));
tableVar= {'occ', 'st', 'dur', 'start', ...
    'iod', 'cod', 'yi', 'xi', 'mdli',...
    'na', 'nb', 'nc', 'model'};
tab.Properties.VariableNames = tableVar;


%% Prediction model parameters

tic;
load rt


occnum = 1;
sampletime = 5; %min
duration1min = 60*24*60; %sec
startnum = 1; %with timestep
iodelay = 1;
codelay = 1;
dependentvar_index = 1;               %Tin : 1, Gas : 3, delT : 12
indepedentvar_index = 15;
modeling_index = 2;                    %Lrg : 1, arx : 2, armax : 3, nlarx : 4
na = 5;
nb = 5;
nc = 5;


PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
    iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
    na, nb, nc];


%% Make Prediction models

switch modeling_index
    case 1
        
    case 2
    [mdl, order, X, Y, iddata] = PredictionModel(rt, PredictionModelParameters);
end

%% Send to ARX_2_Matrix

switch dependentvar_index
    case 1
        dep = 'tin';
    case 3
        dep = 'gas';
    case 12
        dep = 'delT';
end

file_loc = sprintf('C:\\MPCframework\\ARX_2_Matrix\\%s_4_matrix.mat', dep);
idd = iddata;
save(file_loc, 'mdl', 'order', 'X', 'Y', 'idd');


%% Send to Framework in MATLAB
tic;
load rt


occnum = 1;
sampletime = 5; %min
duration1min = 60*24*30; %min
startnum = (60*24*60)/5; %with timestep
iodelay = 1;
codelay = 1;              %Tin : 1, Gas : 3, delT : 12
modeling_index = 2;                    %Lrg : 1, arx : 2, armax : 3, nlarx : 4
na = 10;
nb = 10;
nc = 10;

PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
    iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
    na, nb, nc];

switch modeling_index
    case 1
        
    case 2
    [mdl, order, X, Y, iddata] = PredictionModel(rt, PredictionModelParameters);
end

switch dependentvar_index
    case 1
        dep = 'tin';
    case 3
        dep = 'gas';
    case 12
        dep = 'delT';
end

file_loc = sprintf('C:\\MPCframework\\ARX_2_Matrix\\%s_4_matrix_VirtualBuilding.mat', dep);
save(file_loc, 'mdl', 'order', 'X', 'Y', 'idd');


toc;
%% parfor v.s. for
% tic;
% parfor iodelay = 1:100
%     
% PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
%     iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
%     na, nb, nc];
% 
% 
% mdl = PredictionModel(rt, PredictionModelParameters);
% end
% toc;
% 
% tic;
% for iodelay = 1:100
%     
% PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
%     iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
%     na, nb, nc];
% 
% 
% mdl = PredictionModel(rt, PredictionModelParameters);
% end
% toc;