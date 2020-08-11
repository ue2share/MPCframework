load rt

occnum_cand = 1; %fix
% sampletime_cand = [5 10 15 20 30 60]; % for loop
sampletime_cand = [5]; % for loop
% duration1min_cand = [60*24*7 60*24*14 60*24*30 60*24*60]; % for loop
duration1min_cand = [60*24*7]; % for loop
startnum_cand = 1000; %fix
independentVar_cand = [];
io_delay_cand = 1:5;
co_delay_cand = 1:5;
na_cand = 1:5;
nb_cand = 1:5;
nc_cand = 1:5;
dependentVar_cand = [1, 3, 12]; %['tin', 'gas', 'delT'];
modeling_cand = ['lrg', 'arx', 'armax', 'narx'];


%% Outputnum parameters

outputnum_total = [1 3 12]; %Output is tin, gas, or delta T.

%% inputnum parameters

% Element's candidate for input number
inputset_total_raw_tin = [2 5 7 8];
inputset_total_raw_gas = [1 2 5 7 8];
inputset_total_raw_delT = [1 2 5 7 8];


% Candidate sets for input number
inputset_total_tin = {};
inputset_total_gas = {};
inputset_total_delT = {};

for n = 1:5
    if n<=length(inputset_total_raw_tin)
        s = nchoosek(inputset_total_raw_tin, n);
        for m = 1:size(s)
           inputset_total_tin{end+1} = s(m, :);
        end
    end
    
    s = nchoosek(inputset_total_raw_gas, n);
    for m = 1:size(s)
       inputset_total_gas{end+1} = s(m, :);
       inputset_total_delT{end+1} = s(m, :);
    end
    
end

% Number of inputset
num_inputset_tin = length(inputset_total_tin);
num_inputset_gas = length(inputset_total_gas);
num_inputset_delT = length(inputset_total_delT);

num_inputset_max = max([num_inputset_delT, num_inputset_gas, num_inputset_tin]);

%% Define Database value

numocc = length(occnum_cand);
numsampletime = length(sampletime_cand);
numduration1min = length(duration1min_cand);
numstartnum = length(startnum_cand);
numio = length(io_delay_cand);
numco = length(co_delay_cand);
numna = length(na_cand);
numnb = length(nb_cand);
numnc = length(nc_cand);
nummodel = length(modeling_cand);
numdependentvar = length(dependentVar_cand);
numindependentvar = length(independentVar_cand);

[tin_x, tin_y]=...
    deal(cell(numocc, numsampletime, numduration1min, numstartnum,...
    numio, numco,...
    nummodel, numdependentvar, numindependentvar));
global t duration
for occnum_index = 1:numocc
%% Occnum
% rt has all raw table with occnumber.
    t = rt{occnum_index};

    
for sampletime_index = 1:numsampletime
%% Model Time resolution(sampletime)
% Cut raw table with sampletime.
timeResolution = sampletime_cand(sampletime_index);
tsgroup = @(ts) 1:ts:172800;
t = t(tsgroup(timeResolution), :);


for duration_index = 1:numduration1min
%% Prediction model duration
duration_1min = duration1min_cand(duration_index);
duration = duration_1min/timeResolution;


for start_index = 1:numstartnum
%% Decide start number in raw data.(Start number of prediction models)
startnum = startnum_cand(start_index);


for io_index = 1:numio
%% Input-Output delay
iodelay = io_delay_cand(io_index);


for co_index = 1:numco
%% Control Variable - Output delay
codelay = co_delay_cand(co_index);

for dependentvar_index = 1:numdependentvar
%% Dependent variables(Tin, Gas, delT)
ynum = dependentVar_cand(dependentvar_index);

    

% independent variables depend on dependent variables.
switch ynum
    case 1
        inputset = inputset_total_tin;
        numindependentvar = num_inputset_tin;
    case 3
        inputset = inputset_total_gas;
        numindependentvar = num_inputset_gas;
    case 12
        inputset = inputset_total_delT;
        numindependentvar = num_inputset_delT;
end

for independentvar_index = 1:numindependentvar
%% Independent variables

    
for na_index = 1:numna
%% na - order of ar-models.(Number of poles)
na = na_cand(na_index);


for nb_index = 1:numnb
%% nb - order of ar-models.(Number of zeros)
nb = nb_cand(nb_index);


for nc_index = 1:numnc
%% nc - order of ar-models.(Number of C coefficients)
nc = nc_cand(nc_index);




    
    
    
    
    
    
    
    
end 
end
end
end
end
end
end
end
end
end
end



