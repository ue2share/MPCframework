%% Test with gas



global p q r h t
for ii = 1:2
    if ii==1
        load gas_4_matrix.mat
    else
        load gas_4_matrix_VirtualBuilding.mat
    end
    

% for k = kset
p = order(1);    % p = model horizon = arx's model order
[~, q] = size(X);    % q = # of inputs and control inputs
r = 2;    % r = # of inputs = r
h = 36;   % n = Prediction horizon
t = 110;  % k = Stargasg number

p_gas = p;
h_gas = h;
% gas - signal, tout, elec, rhout, bsp

%% Data (no delay)
% y is output         (gas)
% x is input          (tout elec rhout)
% u is control input  (signal boilerSetPoint)

arx_gas = mdl;
ym_gas = Y;                 % y measured
xm_gas = X(:, 3:end);        % x measured (tout elec rhout)
um_gas = X(:, 1:2);


ugroup1 = group_data(um_gas, t-p+2, p+h-1);
xgroup1 = group_data(xm_gas, t-p+2, p+h-1);

u_past_group = group_data(um_gas, t-p+2, p-1); % (t-p+2)*r+1 ~ t*r
u_cont_group = group_data(um_gas, t+1, h);   % (t+1)*r+1  ~ (k+p+h-1)*r
x_group = group_data(xm_gas, t-p+2, p+h-1);

%% Matrix for gas - A, B, C, D, E
%--------------------------------------   A matrix   -----------------------------------------%
A_original = arx_gas.A;
A_sizecontrol = A_original/A_original(1);  % set coefficient of y(k+p) as 1
A_nofirst = A_sizecontrol(2:end);          % Delete first element which is for y(k+p)
A_nofirst_flip = flip(A_nofirst);          % Order the matrix as first element indicates y(k), second indicates y(k+1)..., last indicatesy(k+p-1)
A_gas = (-1)*A_nofirst_flip;                   % Toss the matrix opposite side of equation

%--------------------------------------   B1, B2 matrix   -----------------------------------------%
B_cell = arx_gas.B;
B_original = cat(1, B_cell{:});
B_up = B_original(1:r, :);
B_up_flip = flip(B_up, 2);
B1 = reshape(B_up_flip, p*r, 1)';

% Compute matrix B2, coefficient matrix of x
B_down = B_original(r+1:end, :);
B_down_flip = flip(B_down, 2);
B2 = reshape(B_down_flip, p*(q-r), 1)';

%------------------------------------   C, D, E matrix   ---------------------------------------%
C_up = [zeros(p-1, 1) eye(p-1)];
C_gas = [C_up;A_gas];

D_up = zeros((p-1), p*r);
D = [D_up; B1];

E_up = zeros((p-1), p*(q-r));
E = [E_up; B2];

%% Matrix for gas - T, U, V

% y = T*u_group + U*x_group + V

%--------------------------------------   T matrix   -----------------------------------------%
T = zeros(h, (p+h-1)*r);
for n = 1:h
for i = n:h
    if n==1
        T(i, 1+(i-n)*r:(i-n+p)*r) = T(i, 1+(i-n)*r:(i-n+p)*r) + B1;
    else
        T(i, 1+(i-n)*r:(i-n+p)*r) = T(i, 1+(i-n)*r:(i-n+p)*r) + A_gas*C_gas^(n-2)*D;
    end
end
end
%--------------------------------------   U matrix   -----------------------------------------%
U_gas = zeros(h, (p+h-1)*(q-r));
for n = 1:h
for i = n:h
    if n==1
        U_gas(i, 1+(i-n)*(q-r):(i-n+p)*(q-r)) = U_gas(i, 1+(i-n)*(q-r):(i-n+p)*(q-r)) + B2;
    else
        U_gas(i, 1+(i-n)*(q-r):(i-n+p)*(q-r)) = U_gas(i, 1+(i-n)*(q-r):(i-n+p)*(q-r)) + A_gas*C_gas^(n-2)*E;
    end
end
end

% V matrix needs data

%% Matrix for T1, T2

T1_gas = T(:, 1:(p-1)*r);
T2 = T(:, (p-1)*r+1:(h+p-1)*r);

%% Matrix for gas - R1, R2, T, U, V

% y = R1*u1 + R2*u2 + S

%--------------------------------------   R1, 2 matrix   -----------------------------------------%
R1_gas = zeros(h, h);
R2_gas = zeros(h, h);
u1 = zeros(h, 1);
u2 = zeros(h, 1);

for i = 1:2*h
    if rem(i, 2)~=0 % odd number
        R1_gas(:, (i-1)/2+1) = T2(:, i);
        u1((i-1)/2+1, 1) = u_cont_group(i, 1);
    else
        R2_gas(:, i/2) = T2(:, i);
        u2(i/2, 1) = u_cont_group(i, 1);
    end
end

%% Verifying Matrix with particular input set









%% Verifying T, U, V (no delay)


V = zeros(h, 1);
y_p_k = group_data(ym_gas, t-p+1, p);
for n = 1:h
V(n) = A_gas*C_gas^(n-1)*y_p_k;
end

ycalc_TUV = T*ugroup1 + U_gas*xgroup1 + V; 

%% Verifying T1, T2, U, V (no delay)

ugroup3_past = ugroup1(1: (p-1)*r);
ugroup3_cont = ugroup1((p-1)*r+1:end);

ycalc_T1T2UV = T1_gas*ugroup3_past + T2*ugroup3_cont + U_gas*xgroup1 + V;

%% Verifying R1, R2, S (no delay)



ycalc_R1R2S = R1_gas*u1 + R2_gas*u2 + T1_gas*u_past_group + U_gas*x_group + V;

%% Test gas Forecast (no delay)
% Forecasgasg y with forecast function
%------------------------------------------------------------------------%
% Using forecast function - yfore : (k+p) ~ (k+p+m-1)
pastdata_y = ym_gas(t-p+1:t, :);
pastdata_u = um_gas(t-p+1:t, :);
pastdata_x = xm_gas(t-p+1:t, :);
pastdata = [pastdata_y pastdata_u pastdata_x];  % k   ~  k+p-1
futdata_u = um_gas(t+1:t+h, :);
futdata_x = xm_gas(t+1:t+h, :);
futdata = [futdata_u futdata_x];                % k+p ~  k+p+h-1

yfore = forecast(arx_gas, 'r--',  pastdata, h, futdata);

[ycalc_TUV ycalc_T1T2UV ycalc_R1R2S yfore ym_gas(t+1:t+h)]

%% Transfer matrix to optimization of framework.
if ii == 1
    %for optimization
save('C:\MPCframework\Optimization\Matrix_gas.mat', 'A_gas', 'C_gas','R1_gas', 'R2_gas', 'T1_gas', 'U_gas',...
    'ym_gas', 'xm_gas', 'um_gas',...
    'h_gas', 'p_gas');
    %for mpc Controller
save('C:\MPCframework\Framework_in_MATLAB\MatlabController_Matrix_gas.mat', 'A_gas', 'C_gas','R1_gas', 'R2_gas', 'T1_gas', 'U_gas',...
    'ym_gas', 'xm_gas', 'um_gas','h_gas', 'p_gas');
else
    %for VirtualBuilding
    VB_A_gas = A_gas;
    VB_B1_gas = B1;
    VB_B2_gas = B2;
    VB_C_gas = C_gas;
    VB_R1_gas = R1_gas;
    VB_R2_gas = R2_gas;
    VB_T1_gas = T1_gas;
    VB_U_gas = U_gas;
    VB_ym_gas = ym_gas;
    VB_um_gas = um_gas;
    VB_xm_gas = xm_gas;
    VB_h_gas = h_gas;
    VB_p_gas = p_gas;
    VB_model_gas = arx_gas;
    
save('C:\MPCframework\Framework_in_MATLAB\VirtualBuilding_Matrix_gas.mat', 'VB_A_gas', 'VB_C_gas','VB_R1_gas',...
    'VB_R2_gas', 'VB_T1_gas', 'VB_U_gas', 'VB_B1_gas', 'VB_B2_gas',...
    'VB_ym_gas', 'VB_xm_gas', 'VB_um_gas',...
    'VB_h_gas', 'VB_p_gas', 'VB_model_gas');
    
    
end
end