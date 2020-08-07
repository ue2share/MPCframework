%% Test with Tin
load tin_mdl_xy.mat

samplenum = 4;  %test  case

global p q r h t
% for k = kset
p = 6;    % p = model horizon = arx's model order
q = 6;    % q = # of inputs and control inputs
r = 2;    % r = # of inputs = r
h = 36;   % n = Prediction horizon
t = 110;  % k = Starting number

% Tin - signal, tout, elec, rhout, bsp

%% Data & Model (delay)
% y is output         (Tin)
% x is input          (tout elec rhout)
% u is control input  (signal boilerSetPoint)

ord = tin_order_arx{samplenum};
global ym_tin xm_tin um_tin
ym_tin = tin_Y{samplenum}(1001:4000);                 % y measured
xm_tin = tin_X{samplenum}(1001:4000, 3:end);        % x measured (tout elec rhout)
um_tin = tin_X{samplenum}(1001:4000, 1:2);

% Let's assume delay of u is 1, delay of x is 2.
um_tin(2:3000) = um_tin(1:2999);
um_tin(1) = 0;
xm_tin(3:3000) = xm_tin(1:2998);
xm_tin(1:2) = 0;
idd = iddata(ym_tin, [um_tin xm_tin]);
arxsample = arx(idd, ord);

ugroup1 = func_group('um_tin', t-p+2, p+h-1);
xgroup1 = func_group('xm_tin', t-p+2, p+h-1);

u_past_group = func_group('um_tin', t-p+2, p-1); % (t-p+2)*r+1 ~ t*r
u_cont_group = func_group('um_tin', t+1, h);   % (t+1)*r+1  ~ (k+p+h-1)*r
x_group = func_group('xm_tin', t-p+2, p+h-1);

%% Matrix for Tin - A, B, C, D, E
%--------------------------------------   A matrix   -----------------------------------------%
A_original = arxsample.A;
A_sizecontrol = A_original/A_original(1);  % set coefficient of y(k+p) as 1
A_nofirst = A_sizecontrol(2:end);          % Delete first element which is for y(k+p)
A_nofirst_flip = flip(A_nofirst);          % Order the matrix as first element indicates y(k), second indicates y(k+1)..., last indicatesy(k+p-1)
A = (-1)*A_nofirst_flip;                   % Toss the matrix opposite side of equation

%--------------------------------------   B1, B2 matrix   -----------------------------------------%
B_cell = arxsample.B;
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
C = [C_up;A];

D_up = zeros((p-1), p*r);
D = [D_up; B1];

E_up = zeros((p-1), p*(q-r));
E = [E_up; B2];

%% Matrix for Tin - T, U, V

% y = T*u_group + U*x_group + V

%--------------------------------------   T matrix   -----------------------------------------%
T = zeros(h, (p+h-1)*r);
for n = 1:h
for i = n:h
    if n==1
        T(i, 1+(i-n)*r:(i-n+p)*r) = T(i, 1+(i-n)*r:(i-n+p)*r) + B1;
    else
        T(i, 1+(i-n)*r:(i-n+p)*r) = T(i, 1+(i-n)*r:(i-n+p)*r) + A*C^(n-2)*D;
    end
end
end
%--------------------------------------   U matrix   -----------------------------------------%
U = zeros(h, (p+h-1)*(q-r));
for n = 1:h
for i = n:h
    if n==1
        U(i, 1+(i-n)*(q-r):(i-n+p)*(q-r)) = U(i, 1+(i-n)*(q-r):(i-n+p)*(q-r)) + B2;
    else
        U(i, 1+(i-n)*(q-r):(i-n+p)*(q-r)) = U(i, 1+(i-n)*(q-r):(i-n+p)*(q-r)) + A*C^(n-2)*E;
    end
end
end

% V matrix needs data

%% Matrix for T1, T2

T1 = T(:, 1:(p-1)*r);
T2 = T(:, (p-1)*r+1:(h+p-1)*r);

%% Matrix for Tin - R1, R2, T, U, V

% y = R1*u1 + R2*u2 + S

%--------------------------------------   R1, 2 matrix   -----------------------------------------%
R1_tin = zeros(h, h);
R2_tin = zeros(h, h);
u1 = zeros(h, 1);
u2 = zeros(h, 1);

for i = 1:2*h
    if rem(i, 2)~=0 % odd number
        R1_tin(:, (i-1)/2+1) = T2(:, i);
        u1((i-1)/2+1, 1) = u_cont_group(i, 1);
    else
        R2_tin(:, i/2) = T2(:, i);
        u2(i/2, 1) = u_cont_group(i, 1);
    end
end

%% Verifying Matrix with particular input set









%% Verifying T, U, V (no delay)



V = zeros(h, 1);
y_p_k = func_group('ym_tin', t-p+1, p);
for n = 1:h
V(n) = A*C^(n-1)*y_p_k;
end

ycalc_TUV = T*ugroup1 + U*xgroup1 + V; 

%% Verifying T1, T2, U, V (no delay)

ugroup3_past = ugroup1(1: (p-1)*r);
ugroup3_cont = ugroup1((p-1)*r+1:end);

ycalc_T1T2UV = T1*ugroup3_past + T2*ugroup3_cont + U*xgroup1 + V;

%% Verifying R1, R2, S (no delay)



ycalc_R1R2S = R1_tin*u1 + R2_tin*u2 + T1*u_past_group + U*x_group + V;

%% Test Tin Forecast (no delay)
% Forecasting y with forecast function
%------------------------------------------------------------------------%
% Using forecast function - yfore : (k+p) ~ (k+p+m-1)
pastdata_y = ym_tin(t-p+1:t, :);
pastdata_u = um_tin(t-p+1:t, :);
pastdata_x = xm_tin(t-p+1:t, :);
pastdata = [pastdata_y pastdata_u pastdata_x];  % k   ~  k+p-1
futdata_u = um_tin(t+1:t+h, :);
futdata_x = xm_tin(t+1:t+h, :);
futdata = [futdata_u futdata_x];                % k+p ~  k+p+h-1

yfore = forecast(arxsample, 'r--',  pastdata, h, futdata);

[ycalc_TUV ycalc_T1T2UV ycalc_R1R2S yfore ym_tin(t+1:t+h)]





























