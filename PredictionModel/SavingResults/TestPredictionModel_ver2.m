load rt

occnum_cand = 1; %fix
% sampletime_cand = [5 10 15 20 30 60]; % for loop
sampletime_cand = [5]; % for loop
% duration1min_cand = [60*24*7 60*24*14 60*24*30 60*24*60]; % for loop
duration1min_cand = [60*24*7]; % for loop
startnum_cand = 1000; %fix
modeling_cand = ['lrg', 'arx', 'armax', 'narx'];
dependentVar_cand = ['tin', 'gas', 'delT'];
independentVar_cand = [];
io_delay = 1:5;
co_delay = 1:5;
na_cand = 1:5;
nb_cand = 1:5;
nc_cand = 1:5;


samptime_duration_cell =cell([length(sampletime_cand), length(duration1min_cand)]);
global t startindex duration
%% Occnum
occnum = occnum_cand;

%% Outputnum parameters (dependentVar_cand)
outputnum_total = [1 3 12]; %Output is tin, gas, or delta T.

%% inputnum parameters (independentVar_cand)

% Element's candidate for input number
inputset_total_raw_tin = [2 5 7 8];
inputset_total_raw_gas = [1 2];
inputset_total_raw_delT = [1 2 5 7 8];


% Candidate sets for input number
global inputset_total_tin inputset_total_gas inputset_total_delT
inputset_total_tin = {};
inputset_total_gas = {};
inputset_total_delT = {[1 2 5 7 8]};

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
inputset_tin_range = 1:length(inputset_total_tin);
inputset_gas_range = 1:length(inputset_total_gas);
inputset_delT_range = 1:length(inputset_total_delT);

%% Model Time resolution(sampletime)
sampletime = sampletime_cand;


tic;


for timeResolution = sampletime
    
%% Resize raw data table with time resolution
t = rt{occnum};
tsgroup = @(ts) 1:ts:172800;
t = t(tsgroup(timeResolution), :);

%% Prediction model duration
duration_1min = duration1min_cand;
duration_1min = duration_1min/timeResolution;
for duration = duration_1min
   startindex = startnum_cand;

   % X, Y, id
   [inputindex_gas, io_delay, co_delay, na] =...
       ndgrid(inputset_gas_range, io_delay, co_delay, na_cand);
   
   [x, y, id] = arrayfun(@(inputindex_gas, io_delay, co_delay)...
    ionumdelay_2_model_input(inputindex_gas, 3, io_delay, co_delay)...
    ,inputindex_gas, io_delay, co_delay, 'UniformOutput', false);

   % order   
  [inputindex_gas, na, nb, nc] =...
       ndgrid(inputset_gas_range, io_delay, co_delay, na_cand);
   
   [order_arx, order_armax] = arrayfun(@(inputindex_gas, na, nb, nc)...
    order_4_ar_family(inputindex_gas, 3, na, nb, nc)...
    ,inputindex_gas, na, nb, nc, 'UniformOutput', false);
   
    % arx
    arx_mdl = cellfun(@(id, order_arx) arx(id, order_arx),...
    id, order_arx, 'UniformOutput', false);
%    samptime_duration_cell
    
    
end
end


toc;
















