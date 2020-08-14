mFileErrorCode = 100;    % Beginning of the m-file 




%% Load Prediction Model
if ( (trnInfo(7) == 0) & (trnTime-trnStartTime < 1e-6) )  
    load MatlabController_Matrix_tin.mat
    load MatlabController_Matrix_gas.mat
    load MatlabController_Matrix_delT.mat
    
    load tin_inputnum.mat
    load gas_inputnum.mat
    load delT_inputnum.mat
    
    % If you want assign more value, preallocate large size matrix.
    ym_tin = zeros(1000,1);
    ym_gas = zeros(1000,1);
    ym_delT = zeros(1000,1);
    xm_tin = zeros(1000,length(tin_inputnum));
    xm_gas = zeros(1000,length(gas_inputnum));
    xm_delT = zeros(1000,length(delT_inputnum));
    um = zeros(1000, 1);
    
    mFileErrorCode = 120;    % After initialization call
    
end

%% Get IEQ values from TRNSYS
tin = trnInputs(1);
tout = trnInputs(2);
gas = trnInputs(3);
signal = trnInputs(4);
elec = trnInputs(5);
rhin = trnInputs(6);
rhout = trnInputs(7);
occ = trnInputs(8);
rwt = trnInputs(9);
swt = trnInputs(10);
bsp = trnInputs(11);

ym_tin(t) = trnInputs(1);
ym_gas(t) = trnInputs(3);
ym_delT(t) = trnInputs(12);

xm_tin(t, :) = trnInputs(tin_inputnum);
xm_gas(t, :) = trnInputs(gas_inputnum);
xm_delT(t, :) = trnInputs(delT_inputnum);

um = trnInput([4 11]);

mFileErrorCode = 140;



%%
opt_strategy = 1;

start = 160;
run = 30;

t = trnStartTime;

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
tin_lb = 24;
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

%% Save signal to data repository.
um_tin(t+1, 1) = signal_in_tp1;
um_tin(t+1, 2) = bsp_in_tp1;

um_gas(t+1, 1) = signal_in_tp1;
um_gas(t+1, 2) = bsp_in_tp1;

um_delT(t+1, 1) = signal_in_tp1;
um_delT(t+1, 2) = bsp_in_tp1;

%% Toss signal to TRNSYS
trnOutputs(1) = signal_in_tp1;
trnOutputs(2) = bsp_in_tp1;









