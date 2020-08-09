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
inputset_total_raw_gas = [1 2 5 7 8];
inputset_total_raw_delT = [1 2 5 7 8];


% Candidate sets for input number
inputset_total_tin = {[2 5 7 8]};
inputset_total_gas = {[1 2 5 7 8]};
inputset_total_delT = {[1 2 5 7 8]};

% for n = 1:5
%     if n<=length(inputset_total_raw_tin)
%         s = nchoosek(inputset_total_raw_tin, n);
%         for m = 1:size(s)
%            inputset_total_tin{end+1} = s(m, :);
%         end
%     end
%     
%     s = nchoosek(inputset_total_raw_gas, n);
%     for m = 1:size(s)
%        inputset_total_gas{end+1} = s(m, :);
%        inputset_total_delT{end+1} = s(m, :);
%     end
%     
% end


% Number of inputset
num_inputset_tin = length(inputset_total_tin);
num_inputset_gas = length(inputset_total_gas);
num_inputset_delT = length(inputset_total_delT);

num_inputset_max = max([num_inputset_delT, num_inputset_gas, num_inputset_tin]);
%% Delay parameters & Model Order(for ar- model)

iodelay_range = 1:3;
codelay_range = 1:3;
% applyingDelay = DisplayDelay - 1

order_range = 6:6;
% applyingOrder = DisplayOrder - 1

numio = length(iodelay_range);
numco = length(codelay_range);
numord = length(order_range);

%% Estimate Model - Tin
[x_tin, y_tin, iddata_tin, order_arx_tin, order_armax_tin ...
    ,lrg_tin, lrg_mse_tin,...
    arx_tin, arx_mse_tin,...
    armax_tin, armax_mse_tin,...
    narx_tin, narx_mse_tin]...
    = deal(cell(num_inputset_max, numio, numco, numord));

for inputnum_index = 1:num_inputset_tin
    inputnum = inputset_total_tin{inputnum_index};
    for iodelay = iodelay_range
        for codelay = codelay_range    
            for order = order_range

               % Calculate x, y, iddata for tin
                [x_tin{inputnum_index, iodelay, codelay, order},...
                    y_tin{inputnum_index, iodelay, codelay, order},...
                    iddata_tin{inputnum_index, iodelay, codelay, order}]=...
                    ionumdelay_2_model_input(inputnum, 1, iodelay, codelay); 

                % Linear Regression
                lrg_tin{inputnum_index, iodelay, codelay, order}...
                    = fitlm(x_tin{inputnum_index, iodelay, codelay, order},...
                                y_tin{inputnum_index, iodelay, codelay, order});

                % Order calculation
                na=order;
                nb=order;
                nc=order;
                [order_arx_tin{inputnum_index, iodelay, codelay, order},...
                    order_armax_tin{inputnum_index, iodelay, codelay, order}]...
                    = order_4_ar_family(inputnum, na, nb, nc);
                
                % arx
                arx_tin{inputnum_index, iodelay, codelay, order}...
                    =arx(iddata_tin{inputnum_index, iodelay, codelay, order},...
                    order_arx_tin{inputnum_index, iodelay, codelay, order});
                
                % armax
                armax_tin{inputnum_index, iodelay, codelay, order}...
                    =armax(iddata_tin{inputnum_index, iodelay, codelay, order},...
                    order_armax_tin{inputnum_index, iodelay, codelay, order});
                
                % narx
                narx_tin{inputnum_index, iodelay, codelay, order}...
                    =nlarx(iddata_tin{inputnum_index, iodelay, codelay, order},...
                    order_arx_tin{inputnum_index, iodelay, codelay, order});
                
                % lrg - MSE
                lrg_mse_tin{inputnum_index, iodelay, codelay, order}...
                    =lrg_tin{inputnum_index, iodelay, codelay, order}.MSE;
                
                % ar-form - MSE
                arx_mse_tin{inputnum_index, iodelay, codelay, order}...
                    =arx_tin{inputnum_index, iodelay, codelay, order}.Report.Fit.MSE;
                
                armax_mse_tin{inputnum_index, iodelay, codelay, order}...
                    =armax_tin{inputnum_index, iodelay, codelay, order}.Report.Fit.MSE;
                
                narx_mse_tin{inputnum_index, iodelay, codelay, order}...
                    =narx_tin{inputnum_index, iodelay, codelay, order}.Report.Fit.MSE;
                
                %Display the current step
                fprintf('Output : Tin, InputIndex : %d, IOdelay : %d, COdelay : %d, Order : %d\n',...
                    inputnum_index, iodelay, codelay, order)
            end
        end
    end
end


%% Estimate Model - delT
[x_delT, y_delT, iddata_delT, order_arx_delT, order_armax_delT ...
    ,lrg_delT, lrg_mse_delT,...
    arx_delT, arx_mse_delT,...
    armax_delT, armax_mse_delT,...
    narx_delT, narx_mse_delT]...
    = deal(cell(num_inputset_max, numio, numco, numord));

for inputnum_index = 1:num_inputset_delT
    inputnum = inputset_total_delT{inputnum_index};
    for iodelay = iodelay_range
        for codelay = codelay_range    
            for order = order_range

               % Calculate x, y, iddata for delT
                [x_delT{inputnum_index, iodelay, codelay, order},...
                    y_delT{inputnum_index, iodelay, codelay, order},...
                    iddata_delT{inputnum_index, iodelay, codelay, order}]=...
                    ionumdelay_2_model_input(inputnum, 12, iodelay, codelay); 

                % Linear Regression
                lrg_delT{inputnum_index, iodelay, codelay, order}...
                    = fitlm(x_delT{inputnum_index, iodelay, codelay, order},...
                                y_delT{inputnum_index, iodelay, codelay, order});

                % Order calculation
                na=order;
                nb=order;
                nc=order;
                [order_arx_delT{inputnum_index, iodelay, codelay, order},...
                    order_armax_delT{inputnum_index, iodelay, codelay, order}]...
                    = order_4_ar_family(inputnum, na, nb, nc);
                
                % arx
                arx_delT{inputnum_index, iodelay, codelay, order}...
                    =arx(iddata_delT{inputnum_index, iodelay, codelay, order},...
                    order_arx_delT{inputnum_index, iodelay, codelay, order});
                
                % armax
                armax_delT{inputnum_index, iodelay, codelay, order}...
                    =armax(iddata_delT{inputnum_index, iodelay, codelay, order},...
                    order_armax_delT{inputnum_index, iodelay, codelay, order});
                
                % narx
                narx_delT{inputnum_index, iodelay, codelay, order}...
                    =nlarx(iddata_delT{inputnum_index, iodelay, codelay, order},...
                    order_arx_delT{inputnum_index, iodelay, codelay, order});
                
                % lrg - MSE
                lrg_mse_delT{inputnum_index, iodelay, codelay, order}...
                    =lrg_delT{inputnum_index, iodelay, codelay, order}.MSE;
                
                % ar-form - MSE
                arx_mse_delT{inputnum_index, iodelay, codelay, order}...
                    =arx_delT{inputnum_index, iodelay, codelay, order}.Report.Fit.MSE;
                
                armax_mse_delT{inputnum_index, iodelay, codelay, order}...
                    =armax_delT{inputnum_index, iodelay, codelay, order}.Report.Fit.MSE;
                
                narx_mse_delT{inputnum_index, iodelay, codelay, order}...
                    =narx_delT{inputnum_index, iodelay, codelay, order}.Report.Fit.MSE;
                
                %Display the current step
                fprintf('Output : delT, InputIndex : %d, IOdelay : %d, COdelay : %d, Order : %d\n',...
                    inputnum_index, iodelay, codelay, order)
            end
        end
    end
end


%% Estimate Model - gas
[x_gas, y_gas, iddata_gas, order_arx_gas, order_armax_gas ...
    ,lrg_gas, lrg_mse_gas,...
    arx_gas, arx_mse_gas,...
    armax_gas, armax_mse_gas,...
    narx_gas, narx_mse_gas]...
    = deal(cell(num_inputset_max, numio, numco, numord));

for inputnum_index = 1:num_inputset_gas
    inputnum = inputset_total_gas{inputnum_index};
    for iodelay = iodelay_range
        for codelay = codelay_range    
            for order = order_range

               % Calculate x, y, iddata for gas
                [x_gas{inputnum_index, iodelay, codelay, order},...
                    y_gas{inputnum_index, iodelay, codelay, order},...
                    iddata_gas{inputnum_index, iodelay, codelay, order}]=...
                    ionumdelay_2_model_input(inputnum, 3, iodelay, codelay); 

                % Linear Regression
                lrg_gas{inputnum_index, iodelay, codelay, order}...
                    = fitlm(x_gas{inputnum_index, iodelay, codelay, order},...
                                y_gas{inputnum_index, iodelay, codelay, order});

                % Order calculation
                na=order;
                nb=order;
                nc=order;
                [order_arx_gas{inputnum_index, iodelay, codelay, order},...
                    order_armax_gas{inputnum_index, iodelay, codelay, order}]...
                    = order_4_ar_family(inputnum, na, nb, nc);
                
                % arx
                arx_gas{inputnum_index, iodelay, codelay, order}...
                    =arx(iddata_gas{inputnum_index, iodelay, codelay, order},...
                    order_arx_gas{inputnum_index, iodelay, codelay, order});
                
                % armax
                armax_gas{inputnum_index, iodelay, codelay, order}...
                    =armax(iddata_gas{inputnum_index, iodelay, codelay, order},...
                    order_armax_gas{inputnum_index, iodelay, codelay, order});
                
                % narx
                narx_gas{inputnum_index, iodelay, codelay, order}...
                    =nlarx(iddata_gas{inputnum_index, iodelay, codelay, order},...
                    order_arx_gas{inputnum_index, iodelay, codelay, order});
                
                % lrg - MSE
                lrg_mse_gas{inputnum_index, iodelay, codelay, order}...
                    =lrg_gas{inputnum_index, iodelay, codelay, order}.MSE;
                
                % ar-form - MSE
                arx_mse_gas{inputnum_index, iodelay, codelay, order}...
                    =arx_gas{inputnum_index, iodelay, codelay, order}.Report.Fit.MSE;
                
                armax_mse_gas{inputnum_index, iodelay, codelay, order}...
                    =armax_gas{inputnum_index, iodelay, codelay, order}.Report.Fit.MSE;
                
                narx_mse_gas{inputnum_index, iodelay, codelay, order}...
                    =narx_gas{inputnum_index, iodelay, codelay, order}.Report.Fit.MSE;
                
                %Display the current step
                fprintf('Output : gas, InputIndex : %d, IOdelay : %d, COdelay : %d, Order : %d\n',...
                    inputnum_index, iodelay, codelay, order)
            end
        end
    end
end


%% Result

subplot(3, 1, 1)
compare(iddata_tin{1, 1, 1, 6}, arx_tin{1, 1, 1, 6})

subplot(3, 1, 2)
compare(iddata_gas{1, 1, 1, 6}, arx_gas{1, 1, 1, 6})

subplot(3, 1, 3)
compare(iddata_delT{1, 1, 1, 6}, arx_delT{1, 1, 1, 6})

%% Extract 


indexnum_extract = 1;
iodelay_extract = 1;
codelay_extract = 1;
order_extract = 6;

tin_iddata = iddata_tin{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
tin_X = x_tin{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
tin_Y = y_tin{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
tin_order = order_arx_tin{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
tin_mdl = arx_tin{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
save('C:\MPCframework\ARX_2_Matrix\tin_4_matrix.mat', 'tin_iddata', 'tin_X', 'tin_Y', 'tin_order', 'tin_mdl')

gas_iddata = iddata_gas{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
gas_X = x_gas{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
gas_Y = y_gas{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
gas_order = order_arx_gas{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
gas_mdl = arx_gas{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
save('C:\MPCframework\ARX_2_Matrix\gas_4_matrix.mat', 'gas_iddata', 'gas_X', 'gas_Y', 'gas_order', 'gas_mdl')

delT_iddata = iddata_delT{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
delT_X = x_delT{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
delT_Y = y_delT{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
delT_order = order_arx_delT{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
delT_mdl = arx_delT{indexnum_extract, iodelay_extract, codelay_extract, order_extract};
save('C:\MPCframework\ARX_2_Matrix\delT_4_matrix.mat', 'delT_iddata', 'delT_X', 'delT_Y', 'delT_order', 'delT_mdl')













