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
dependentvar_index = 1;               %Tin : 1, Gas : 3, delT : 12
indepedentvar_index = 15;
modeling_index = 2;                    %Lrg : 1, arx : 2, armax : 3, nlarx : 4
na = 5;
nb = 5;
nc = 5;





%% Make Prediction models : Find effect of elec usage in independent variables - Tin

dependentvar_index = 1;
max_index_tin = 15;
Fit_ind = cell([max_index_tin, 2]);
for ind_index = 1:max_index_tin
    
    indepedentvar_index = ind_index;
    PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
        iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
        na, nb, nc];
    [mdl, order, X, Y, iddata] = PredictionModel(rt, PredictionModelParameters);

    Fit_ind{ind_index, 1} = mdl.Report.Fit.FitPercent;
    Fit_ind{ind_index, 2} = InputIndex_2_InputArray(1, ind_index);
end

ind_contains_occ = arrayfun(@(ind) ismember(5, Fit_ind{ind, 2}), 1:max_index_tin);
Fit_ind(:, 3) = num2cell(ind_contains_occ');

ind_not_contains_occ = ~ind_contains_occ;
Fit_ind(:, 4) = num2cell(ind_not_contains_occ');

num_indvar = arrayfun(@(X) length(Fit_ind{X, 2}), 1:max_index_tin);
Fit_ind(:, 5) = num2cell(num_indvar');

tT = cell2table(Fit_ind,'VariableNames', {'Fit', 'Index', 'Elec', 'NoElec', 'NumPredictorSets'});

close all

scatter(tT.NumPredictorSets(tT.Elec), tT.Fit(tT.Elec), 100, 'd')
hold on
scatter(tT.NumPredictorSets(tT.NoElec), tT.Fit(tT.NoElec), 100, 'x')

title('Number of predictor sets (Tin) - FitPercent')
xlabel('Number of predictor sets')
set(gca, 'xtick', 1:4)
ylabel('FitPercent')
legend({'Elec in predictor sets', 'Elec is not in predictor sets'})


%% Make Prediction models : Find effect of predictor sets - Gas

dependentvar_index = 3;
max_index_gas = 31;
Fit_ind = cell([max_index_gas, 2]);
for ind_index = 1:max_index_gas
    
    indepedentvar_index = ind_index;
    PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
        iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
        na, nb, nc];
    
    [mdl, order, X, Y, iddata] = PredictionModel(rt, PredictionModelParameters);

    Fit_ind{ind_index, 1} = mdl.Report.Fit.FitPercent;
    Fit_ind{ind_index, 2} = InputIndex_2_InputArray(3, ind_index);
end

num_indvar = arrayfun(@(X) length(Fit_ind{X, 2}), 1:max_index_gas);
Fit_ind(:, 3) = num2cell(num_indvar');

tT = cell2table(Fit_ind,'VariableNames', {'Fit', 'Index', 'NumPredictorSets'});

close all

scatter(tT.NumPredictorSets,tT.Fit, 100, 'x')

title('Number of predictor sets (Gas) - FitPercent')
xlabel('Number of predictor sets')
set(gca, 'xtick', 1:5)
ylabel('FitPercent')

%% Make Prediction models : Find effect of predictor sets - delT

dependentvar_index = 12;
max_index_delT = 31;
Fit_ind = cell([max_index_delT, 2]);

for ind_index = 1:max_index_delT
    
    indepedentvar_index = ind_index;
    PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
        iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
        na, nb, nc];
    
    [mdl, order, X, Y, iddata] = PredictionModel(rt, PredictionModelParameters);

    Fit_ind{ind_index, 1} = mdl.Report.Fit.FitPercent;
    Fit_ind{ind_index, 2} = InputIndex_2_InputArray(12, ind_index);
end

num_indvar = arrayfun(@(X) length(Fit_ind{X, 2}), 1:max_index_delT);
Fit_ind(:, 3) = num2cell(num_indvar');

tT = cell2table(Fit_ind,'VariableNames', {'Fit', 'Index', 'NumPredictorSets'});

close all

scatter(tT.NumPredictorSets,tT.Fit, 100, 'x')

title('Number of predictor sets (delT) - FitPercent')
xlabel('Number of predictor sets')
set(gca, 'xtick', 1:5)
ylabel('FitPercent')

%%

for dependentvar_index = [3, 12]
    PredictionModelParameters = [occnum, sampletime, duration1min, startnum, ...
        iodelay, codelay, dependentvar_index, indepedentvar_index, modeling_index,...
        na, nb, nc];
    
    [mdl, order, X, Y, iddata] = PredictionModel(rt, PredictionModelParameters);
    mdl.Report.Fit.FitPercent
    Y(105:120, :)
end










