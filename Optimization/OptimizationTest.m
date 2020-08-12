load Matrix_tin.mat
load Matrix_gas.mat
load Matrix_delT.mat

%% Optimization parameters
%=====================================================================%
% obj function : min gas usage
% constraints
%   - integer constraints
%   - signal : [0, 1]
%   - bsp    : [40, 80]
%   - Tin term included in constraints
%   - Tin    : [22 26]
% For simplicity, let's assume there is no time delay in this model.
%=====================================================================%

h = max([h_tin, h_gas, h_delT]);
t = 160;
intcon = 1:2*h;

%% Lower&Upper bounds

u1vars = 1:h;     % signal
u2vars = h+1:2*h; % bsp
lb = zeros(2*h, 1); 
ub = ones(2*h, 1);
lb(u2vars) = 40;
ub(u2vars) = 80;

%% Inequality constraints - Tin
% 22<=[R1 R2]*[u1 u2]' + S_tin<=26

% Calculating S_tin 
u_tin_past_group = group_data(um_tin, t-p_tin+2, p_tin-1); 
x_tin_group = group_data(xm_tin, t-p_tin+2, p_tin+h_tin-1);

V_tin = zeros(h, 1);
y_tin_past = group_data(ym_tin, t-p_tin+1, p_tin);
for n = 1:h
V_tin(n) = A_tin*C_tin^(n-1)*y_tin_past;
end

S_tin = T1_tin*u_tin_past_group + U_tin*x_tin_group + V_tin;

% Set A and b
tin_lb = 26;
tin_ub = 52;
A = [R1_tin R2_tin];
b = tin_ub-S_tin;
A = [A;-A];
b_lb = tin_lb-S_tin;
b = [b;-b_lb];

%% Objective function
f = [R1_gas R2_gas];
f = sum(f);

%% Check above configuration
u_cont_group = group_data(um_tin, t+1, h);
u1 = zeros(h, 1);
u2 = zeros(h, 1);

for i = 1:2*h
    if rem(i, 2)~=0 % odd number
        u1((i-1)/2+1, 1) = u_cont_group(i, 1);
    else
        u2(i/2, 1) = u_cont_group(i, 1);
    end
end

tin_from_data = R1_tin*u1 + R2_tin*u2 + T1_tin*u_tin_past_group + U_tin*x_tin_group + V_tin;

%% Run optimizatinon
options = optimoptions(@intlinprog,'MaxTime', 20);
[x, fval, ~, output] = intlinprog(f, intcon, A, b, [], [], lb, ub, options);

%% Check Optimization result
u_onoff = x(1:h);
u_bsp = x(h+1:2*h);
tin_opt = R1_tin*u_onoff + R2_tin*(u_bsp) + S_tin;


% Calculating S_gas 
u_gas_past_group = group_data(um_gas, t-p_gas+2, p_gas-1); 
x_gas_group = group_data(xm_gas, t-p_gas+2, p_gas+h_gas-1);

V_gas = zeros(h, 1);
y_gas_past = group_data(ym_gas, t-p_gas+1, p_gas);
for n = 1:h
V_gas(n) = A_gas*C_gas^(n-1)*y_gas_past;
end

S_gas = T1_gas*u_gas_past_group + U_gas*x_gas_group + V_gas;

gas = R1_gas*u_onoff + R2_gas*u_bsp + S_gas;

[tin_from_data tin_opt u1 u_onoff u2 u_bsp ym_gas(t+1:t+h) gas]
























