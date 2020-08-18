clear all

%% Load Prediction Model
load MatlabController_Matrix_tin.mat
load MatlabController_Matrix_gas.mat
load MatlabController_Matrix_delT.mat

%% Load virtual building
load VirtualBuilding_Matrix_tin.mat
load VirtualBuilding_Matrix_gas.mat
load VirtualBuilding_Matrix_delT.mat

%% Make Repository for saving data
% If you want assign more value, preallocate large size matrix.
ym_tin = zeros(100000,1);
ym_gas = zeros(100000,1);
ym_delT = zeros(100000,1);
xm_tin = VB_xm_tin;
xm_gas = VB_xm_gas;
xm_delT = VB_xm_delT;
um = zeros(100000, 2);

pmax = max([VB_p_tin, p_gas, p_delT]);
opt_strategy = 1;


%%
start = 1;
run = 30;
for ts_10min = start:start+run
    %%Running Virtual Building
    if ts_10min<=pmax
        ym_tin(ts_10min, 1) = VB_ym_tin(ts_10min, 1);
        ym_gas(ts_10min, 1) = VB_ym_gas(ts_10min, 1);
        ym_delT(ts_10min, 1) = VB_ym_delT(ts_10min, 1);
        
        um(ts_10min, 1) = VB_um_tin(ts_10min, 1);
        um(ts_10min, 2) = VB_um_tin(ts_10min, 2);
    else
        y_tin = group_data(ym_tin, ts_10min-VB_p_tin+1, VB_p_tin);
        u_tin = group_data(um, ts_10min-VB_p_tin+2, VB_p_tin);
        x_tin = group_data(VB_xm_tin, ts_10min-VB_p_tin+2, VB_p_tin);

        ym_tin(ts_10min+1, 1)=VB_A_tin*y_tin + VB_B1_tin*u_tin + VB_B2_tin*x_tin;
        
        y_gas = group_data(ym_gas, ts_10min-VB_p_gas+1, VB_p_gas);
        u_gas = group_data(um, ts_10min-VB_p_gas+2, VB_p_gas);
        x_gas = group_data(VB_xm_gas, ts_10min-VB_p_gas+2, VB_p_gas);

        ym_gas(ts_10min+1, 1)=VB_A_gas*y_gas + VB_B1_gas*u_gas + VB_B2_gas*x_gas;

    
    %% Optimization
    switch opt_strategy
    %% Optimization Strategy 1
    case 1
        %% Prediction horizon
          h = max([h_tin, h_gas, h_delT]);

        %% Lower&upper bounds 
        u1vars = 1:h;     % signal
        u2vars = h+1:2*h; % bsp
        lb = zeros(2*h, 1); 
        ub = ones(2*h, 1);
        lb(u2vars) = 40;
        ub(u2vars) = 80;

        %% Inequality constraints - Tin
        % 22<=[R1 R2]*[u1 u2]' + S_tin<=26

        % Calculating S_tin 
        u_tin_past_group = group_data(um, ts_10min-p_tin+2, p_tin-1); 
        x_tin_group = group_data(VB_xm_tin, ts_10min-p_tin+2, p_tin+h_tin-1);


        V_tin = zeros(h, 1);
        y_tin_past = group_data(ym_tin, ts_10min-p_tin+1, p_tin);
        for n = 1:h
        V_tin(n) = A_tin*C_tin^(n-1)*y_tin_past;
        end

        S_tin = T1_tin*u_tin_past_group + U_tin*x_tin_group + V_tin;

        %% Calculating Occ
        occ = group_data(VB_xm_tin(:, 4), ts_10min+1, h);
        occ_index = find(occ==0);
        % Set A and b
        tin_lb = 22;
        tin_ub = 28;
        A = [R1_tin R2_tin];
        b = tin_ub-S_tin;
        b(occ_index) = 100;
        A = [A;-A];
        b_lb = tin_lb-S_tin;
        b_lb(occ_index) = -100;
        b = [b;-b_lb];

        %% Objective function
        f = [R1_gas R2_gas];
        f = sum(f);

        %% Run optimizatinon
        options = optimoptions(@intlinprog,'MaxTime', 10, 'Display', 'final');
        intcon = 1:2*h;
        try
            [x, fval, ~, output] = intlinprog(f, intcon, A, b, [], [], lb, ub, options);
            u_onoff = x(1:h);
            u_bsp = x(h+1:2*h);
        catch
            u_onoff = 1;
            u_bsp = 60;
        end


    signal_in_tp1 = u_onoff(1);
    bsp_in_tp1 = u_bsp(1);

    end

    %% Toss signal to building
    um(ts_10min+1, 1) = signal_in_tp1;
    um(ts_10min+1, 2) = bsp_in_tp1;
    end
%% Display output
[ym_tin(start:start+run),...
    VB_xm_tin(start:start+run, 4),...
    um(start:start+run, 1),...
    um(start:start+run, 2),...
    ym_gas(start:start+run, 1)*10^(-3)]
end










