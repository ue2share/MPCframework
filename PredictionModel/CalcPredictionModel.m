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
sampletime = 10; %min
duration1min = 60*24*60; %sec
startnum = 10; %with timestep
iodelay = 1;
codelay = 1;
% dependentvar_index = 1;               %Tin : 1, Gas : 3, delT : 12
% indepedentvar_index = 15;
modeling_index = 2;                    %Lrg : 1, arx : 2, armax : 3, nlarx : 4
% na = 5;
% nb = 5;
% nc = 5;


PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
    iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
    na, nb, nc];


%% Make Prediction models

switch modeling_index
    case 1
        
    case 2
    [mdl, order, X, Y, iddata] = PredictionModel(rt, PredictionModelParameters);
end
%% Save um_xm_like_TRNSYS
startnum_Jan_min = (30+31)*24*60;
startnum_Jan = startnum_Jan_min/sampletime+1;
Jan_2_Feb_min = (31+28)*24*60;
Jan_2_Feb = Jan_2_Feb_min/sampletime;
inputarr = InputIndex_2_InputArray(dependentvar_index, indepedentvar_index);
tsgroup = @(ts) 1:ts:172800;
t_10min = t(tsgroup(sampletime), :);

um_xm_like_trnsys = PredictionModelPar_2_ModelInput(t_10min, startnum_Jan, Jan_2_Feb,...
    inputarr, dependentvar_index, iodelay, codelay);


%% Send to ARX_2_Matrix

switch dependentvar_index
    case 1
        dep = 'tin';
        tin_um_xm_like_trnsys = um_xm_like_trnsys;
    case 3
        dep = 'gas';
        gas_um_xm_like_trnsys = um_xm_like_trnsys;
    case 12
        dep = 'delT';
        delT_um_xm_like_trnsys = um_xm_like_trnsys;
end
file_loc = sprintf('C:\\MPCframework\\Framework_in_TRNSYS\\%s_umxm.mat', dep);
input_name = sprintf('%s_um_xm_like_trnsys', dep);
save(file_loc, input_name);

file_loc = sprintf('C:\\MPCframework\\ARX_2_Matrix\\%s_4_matrix.mat', dep);
idd = iddata;
save(file_loc, 'mdl', 'order', 'X', 'Y', 'idd');


%% Send to Matrix folder to make Framework in MATLAB
tic;
load rt


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

%% Send inpunum&outputnum to MPCframework_TRNSYS
inputnum = InputIndex_2_InputArray(dependentvar_index, indepedentvar_index);

switch dependentvar_index
    case 1
        dep = 'tin';
        tin_inputnum = inputnum;
    case 3
        dep = 'gas';
        gas_inputnum = inputnum;
    case 12
        dep = 'delT';
        delT_inputnum = inputnum;
end

file_loc = sprintf('C:\\MPCframework\\Framework_in_TRNSYS\\%s_inputnum.mat', dep);
input_name = sprintf('%s_inputnum', dep);
save(file_loc, input_name, 'sampletime');


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