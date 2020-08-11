function [ model ] = PredictionModel(rawtable, PredictionModelParameters)

occnum              =PredictionModelParameters(1);
sampletime          =PredictionModelParameters(2);
duration1min        =PredictionModelParameters(3);
startnum            =PredictionModelParameters(4);
iodelay             =PredictionModelParameters(5);
codelay             =PredictionModelParameters(6);
dependentvar_index  =PredictionModelParameters(7);
indepedentvar_index =PredictionModelParameters(8);
modeling_index      =PredictionModelParameters(9);
na                  =PredictionModelParameters(10);
nb                  =PredictionModelParameters(11);
nc                  =PredictionModelParameters(12);
%% Occnum
t = rawtable{occnum};


%% Model Time resolution(sampletime)
% Cut raw table with sampletime.
tsgroup = @(ts) 1:ts:172800;
t = t(tsgroup(sampletime(:)), :);


%% Model duration
duration = duration1min/sampletime;

%% Ouputnum parameters


%% Inputnum parameters
inputarray = InputIndex_2_InputArray(dependentvar_index, indepedentvar_index);

%% Modeling Method

switch modeling_index
    case 1 % Linear Regression
    [X, Y, ~] = PredictionModelPar_2_ModelInput(t, startnum, duration, inputarray,...
        dependentvar_index, iodelay, codelay);
    model = fitlm(X, Y);

    case 2 % ARX
    [~, ~, iddata] = PredictionModelPar_2_ModelInput(t, startnum, duration, inputarray,...
    dependentvar_index, iodelay, codelay);  
    [order, ~] = order_4_ar_family(inputarray, na, nb, nc);
    model = arx(iddata, order);

    case 3 % ARMAX
    [~, ~, iddata] = PredictionModelPar_2_ModelInput(t, startnum, duration, inputarray,...
    dependentvar_index, iodelay, codelay);  
    [~, order] = order_4_ar_family(inputarray, na, nb, nc);
    model = armax(iddata, order);
    
    case 4 % NARX
    [~, ~, iddata] = PredictionModelPar_2_ModelInput(t, startnum, duration, inputarray,...
    dependentvar_index, iodelay, codelay);  
    [order, ~] = order_4_ar_family(inputarray, na, nb, nc);
    model = nlarx(iddata, order);

end

