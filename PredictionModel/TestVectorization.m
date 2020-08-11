load rt



%% Occnum
global t
occnum = 1;
t = rt{occnum};

%% Model length
global init_num duration
init_num = 1000;
duration = 6*24*30;

%% Outputnum parameters

outputnum_total = [1 3 12]; %Output is tin, gas, or delta T.

num_output = length(outputnum_total);
%% inputnum parameters

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
num_inputset_tin = length(inputset_total_tin);
num_inputset_gas = length(inputset_total_gas);
num_inputset_delT = length(inputset_total_delT);

num_inputset_max = max([num_inputset_delT, num_inputset_gas, num_inputset_tin]);


%% Estimate Model with vectorization

inputindex_range = 1:num_inputset_gas;
io_range = 1:5;
co_range = 1:5;
na_range = 1:3;
nb_range = 1:3;
nc_range = 1:3;


tic;


[inputindex, io, co] = ndgrid(inputindex_range, io_range, co_range);
[x, y, id] = arrayfun(@(inputindex, io, co)...
    ionumdelay_2_model_input(inputindex, 3, io, co)...
    ,inputindex, io, co, 'UniformOutput', false);


[inputindex, na, nb, nc] = ndgrid(inputindex_range, na_range, nb_range, nc_range);
[order_arx, order_armax] = arrayfun(@(inputindex, na, nb, nc)...
    order_4_ar_family(inputindex, 3, na, nb, nc)...
    ,inputindex, na, nb, nc, 'UniformOutput', false);

[id_, order_arx_] = ndgrid(id, order_arx)
arx_mdl = cellfun(@(id, order_arx) arx(id, order_arx),...
    id, order_arx, 'UniformOutput', false);



toc;



%%
% tic;
% [xfor, yfor, idfor, ord_ar_for, arxmdl_for]=...
%     deal(cell(3, 3, 3));
% 
% try
% for ii = 1:31
%     for i=1:3
%         for j=1:3
%             for k=1:3
%                 [xfor{ii, i, j, k}, yfor{ii, i, j, k}, idfor{ii, i, j, k}]...
%                     = ionumdelay_2_model_input(ii, 3, i, j);
%                 [ord_ar_for{ii, i, j, k}, ~] = order_4_ar_family(ii, 3, i, j, k);
%                 arxmdl_for{ii, i, j, k} = arx(idfor{ii, i, j, k}, ord_ar_for{ii, i, j, k});
%             end
%         end
%     end
% end
% toc;
% catch E
% [ii i j k]
% end

















