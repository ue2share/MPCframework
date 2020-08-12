clear all

%% Load Prediction Model
load MatlabController_Matrix_tin.mat
load MatlabController_Matrix_gas.mat
load MatlabController_Matrix_delT.mat

%% Load virtual building
load VirtualBuilding_Matrix_tin.mat
load VirtualBuilding_Matrix_gas.mat
load VirtualBuilding_Matrix_delT.mat


opt_strategy = 1;

t = 160; %Start timestep

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
u_tin_past_group = group_data(VB_um_tin, t-p_tin+2, p_tin-1); 
x_tin_group = group_data(VB_xm_tin, t-p_tin+2, p_tin+h_tin-1);

V_tin = zeros(h, 1);
y_tin_past = group_data(VB_ym_tin, t-p_tin+1, p_tin);
for n = 1:h
V_tin(n) = A_tin*C_tin^(n-1)*y_tin_past;
end

S_tin = T1_tin*u_tin_past_group + U_tin*x_tin_group + V_tin;

% Set A and b
tin_lb = 20;
tin_ub = 52;
A = [R1_tin R2_tin];
b = tin_ub-S_tin;
A = [A;-A];
b_lb = tin_lb-S_tin;
b = [b;-b_lb];

    %% Objective function
f = [R1_gas R2_gas];
f = sum(f);

    %% Run optimizatinon
options = optimoptions(@intlinprog,'MaxTime', 20);
intcon = 1:2*h;
[x, fval, ~, output] = intlinprog(f, intcon, A, b, [], [], lb, ub, options);

u_onoff = x(1:h);
u_bsp = x(h+1:2*h);
        
signal_in_tp1 = u_onoff(1);
bsp_in_tp1 = u_bsp(1);
        
end

%% Toss signal to building
VB_um_tin(t+1, 1) = signal_in_tp1;
VB_um_tin(t+1, 2) = bsp_in_tp1;

VB_um_gas(t+1, 1) = signal_in_tp1;
VB_um_gas(t+1, 2) = bsp_in_tp1;

VB_um_delT(t+1, 1) = signal_in_tp1;
VB_um_delT(t+1, 2) = bsp_in_tp1;

%% Run building for get Tin, Gas, delT in t+1.
% calculate output of arx function with compare function.
y_tin = group_data(VB_ym_tin, t-VB_p_tin+1, VB_p_tin);
u_tin = group_data(VB_um_tin, t-VB_p_tin+2, VB_p_tin);
x_tin = group_data(VB_xm_tin, t-VB_p_tin+2, VB_p_tin);

VB_A_tin*y_tin + VB_B1_tin*u_tin + VB_B2_tin*x_tin
VB_ym_tin(t)
VB_ym_tin(t+1)












