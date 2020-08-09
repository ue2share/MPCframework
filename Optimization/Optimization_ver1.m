%% Tin
load tin_mdl_xy.mat


samplenum = 4;  %test  case
global p q r h t
% for k = kset
p = 6;    % p = model horizon = arx's model order
r = 2;    % r = # of inputs = r
h = 36;   % n = Prediction horizon
t = 160;  % k = Starting number
arxsample = tin_arx_mdl{samplenum};
% Tin - signal, tout, elec, rhout, bsp

%% Matrix for Tin - A, B, C, D, E
% y is output         (Tin)
% x is input          (tout elec rhout)
% u is control input  (signal boilerSetPoint)
global ym_tin xm_tin um_tin
ym_tin = tin_Y{samplenum};                 % y measured
xm_tin = tin_X{samplenum}(:, 3:end);        % x measured (tout elec rhout)
um_tin = tin_X{samplenum}(:, 1:2);

q = 6;    % q = # of inputs and control inputs

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
%--------------------------------------   V matrix   -----------------------------------------%
V = zeros(h, 1);
y_p_k = func_group('ym_tin', t-p+1, p);
for n = 1:h
V(n) = A*C^(n-1)*y_p_k;
end

%% Matrix for Tin - R, S, R1, R2

% y = R*u_cont_group + S

%--------------------------------------   R matrix   -----------------------------------------%
R_tin = T(:, (p-1)*r+1:(h+p-1)*r);
%-----------------------------------  T1, T2, S matrix  --------------------------------------%
% r = # of control inputs = 2
T1 = T(:, 1:(p-1)*r);
T2 = R_tin;
u_past_group = func_group('um_tin', t-p+2, p-1); % (k+1)*r  ~ (k+p-1)*r  
u_cont_group = func_group('um_tin', t+1, h);   % (k+p)*r  ~ (k+p+h-1)*r
x_group = func_group('xm_tin', t-p+2, p+h-1);
S_tin = T1*u_past_group + U*x_group + V;

% y = R1*u1 + R2*u2 + S

%--------------------------------------   R1, 2 matrix   -----------------------------------------%
R1_tin = zeros(h, h);
R2_tin = zeros(h, h);
u1 = zeros(h, 1);
u2 = zeros(h, 1);

for i = 1:2*h
    if rem(i, 2)~=0 % odd number
        R1_tin(:, (i-1)/2+1) = R_tin(:, i);
        u1((i-1)/2+1, 1) = u_cont_group(i, 1);
    else
        R2_tin(:, i/2) = R_tin(:, i);
        u2(i/2, 1) = u_cont_group(i, 1);
    end
end

%% Considering Occ + multipicate signal to bsp(H matrix in QP form)

% Occupancy Sample
occ_vector = ones(h, 1);
occ_vector(15:25) = 0;
occ_mat = diag(occ_vector);

% multiplicate signal to bsp
%--------------------------------------   H matrix   -----------------------------------------%
H_tin = [occ_mat*R1_tin occ_mat*R2_tin; zeros(h, 2*h)];

meanTin_in_PredictionHorizon = ([u1' u2']*H_tin*[u1;u2] + occ_vector'*S_tin)/sum(occ_vector);

%% rwt
load swtrwt_mdl_xy.mat

close all
kset = [110 1780 2135 4133];

arxsample = rwt_arx_mdl{samplenum};
% rwt - signal, tout, elec, rhout, bsp

%% Matrix for rwt - A, B, C, D, E
% y is output         (rwt)
% x is input          (tout elec rhout)
% u is control input  (signal boilerSetPoint)
global ym_rwt xm_rwt um_rwt
ym_rwt = rwt_Y{samplenum};                 % y measured
xm_rwt = rwt_X{samplenum}(:, 3:end);        % x measured (tout elec rhout)
um_rwt = rwt_X{samplenum}(:, 1:2);

q = 6;    % q = # of inputs and control inputs

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

%% Matrix for rwt - T, U, V

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
%--------------------------------------   V matrix   -----------------------------------------%
V = zeros(h, 1);
y_p_k = func_group('ym_rwt', t-p+1, p);
for n = 1:h
V(n) = A*C^(n-1)*y_p_k;
end

%% Matrix for rwt - R, S, R1, R2

% y = R*u_cont_group + S

%--------------------------------------   R matrix   -----------------------------------------%
R_rwt = T(:, (p-1)*r+1:(h+p-1)*r);
%-----------------------------------  T1, T2, S matrix  --------------------------------------%
% r = # of control inputs = 2
T1 = T(:, 1:(p-1)*r);
T2 = R_rwt;
u_past_group = func_group('um_rwt', t-p+2, p-1); % (k+1)*r  ~ (k+p-1)*r  
u_cont_group = func_group('um_rwt', t+1, h);   % (k+p)*r  ~ (k+p+h-1)*r
x_group = func_group('xm_rwt', t-p+2, p+h-1);
S_rwt = T1*u_past_group + U*x_group + V;

% y = R1*u1 + R2*u2 + S

%--------------------------------------   R1, 2 matrix   -----------------------------------------%
R1_rwt = zeros(h, h);
R2_rwt = zeros(h, h);
u1 = zeros(h, 1);
u2 = zeros(h, 1);

for i = 1:2*h
    if rem(i, 2)~=0 % odd number
        R1_rwt(:, (i-1)/2+1) = R_rwt(:, i);
        u1((i-1)/2+1, 1) = u_cont_group(i, 1);
    else
        R2_rwt(:, i/2) = R_rwt(:, i);
        u2(i/2, 1) = u_cont_group(i, 1);
    end
end

%% swt

arxsample = swt_arx_mdl{samplenum};

%% Matrix for swt - A, B, C, D, E
% y is output         (swt)
% x is input          (tout elec rhout)
% u is control input  (signal boilerSetPoint)
global ym_swt xm_swt um_swt
ym_swt = swt_Y{samplenum};                 % y measured
xm_swt = swt_X{samplenum}(:, 3:end);        % x measured (tout elec rhout)
um_swt = swt_X{samplenum}(:, 1:2);

q = 6;    % q = # of inputs and control inputs

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

%% Matrix for swt - T, U, V

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
%--------------------------------------   V matrix   -----------------------------------------%
V = zeros(h, 1);
y_p_k = func_group('ym_swt', t-p+1, p);
for n = 1:h
V(n) = A*C^(n-1)*y_p_k;
end

%% Matrix for swt - R, S, R1, R2

% y = R*u_cont_group + S

%--------------------------------------   R matrix   -----------------------------------------%
R_swt = T(:, (p-1)*r+1:(h+p-1)*r);
%-----------------------------------  T1, T2, S matrix  --------------------------------------%
% r = # of control inputs = 2
T1 = T(:, 1:(p-1)*r);
T2 = R_swt;
u_past_group = func_group('um_swt', t-p+2, p-1); % (k+1)*r  ~ (k+p-1)*r  
u_cont_group = func_group('um_swt', t+1, h);   % (k+p)*r  ~ (k+p+h-1)*r
x_group = func_group('xm_swt', t-p+2, p+h-1);
S_swt = T1*u_past_group + U*x_group + V;

% y = R1*u1 + R2*u2 + S

%--------------------------------------   R1, 2 matrix   -----------------------------------------%
R1_swt = zeros(h, h);
R2_swt = zeros(h, h);
u1 = zeros(h, 1);
u2 = zeros(h, 1);

for i = 1:2*h
    if rem(i, 2)~=0 % odd number
        R1_swt(:, (i-1)/2+1) = R_swt(:, i);
        u1((i-1)/2+1, 1) = u_cont_group(i, 1);
    else
        R2_swt(:, i/2) = R_swt(:, i);
        u2(i/2, 1) = u_cont_group(i, 1);
    end
end

%% Optimization

u1vars = 1:h;
u2vars = h+1:2*h;

lb = zeros(2*h, 1);
ub = ones(2*h, 1);
lb(u2vars) = 30;
ub(u2vars) = 80;

TinConst = [R1_tin.*occ_vector R2_tin.*occ_vector];
A = TinConst;
setpoint = 24;
boundary = 3;
TinUb = occ_vector.*((setpoint+boundary)*ones(h, 1)-S_tin);
b = TinUb;

TinLb = (-1)*(occ_vector.*((setpoint-boundary)*ones(h, 1)-S_tin));
A = [A;-TinConst];
b = [b;TinLb];

f = [R1_swt-R1_rwt R2_swt-R2_rwt];
f = sum(f, 1);
intcon = 1:2*h;

options = optimoptions(@intlinprog,'MaxTime', 20);
[x, fval, ~, output] = intlinprog(f, intcon, A, b, [], [], lb, ub, options);

u_onoff = x(1:h);
u_bsp = x(h+1:2*h);
tin = R1_tin*u_onoff + R2_tin*(u_bsp) + S_tin;
rwt = (R1_rwt*u_onoff + R2_rwt*u_bsp + S_rwt);
swt = (R1_swt*u_onoff + R2_swt*u_bsp + S_rwt);
ot = [tin rwt swt u_onoff u_bsp occ_vector]

%% Plotting Result
close all

subplot(2, 1, 1)
plot(1:h, rwt)
hold on
plot(1:h, swt)
hold on
plot(1:h, swt-rwt)
hold on
plot(1:h, u_bsp)
title('Water Temperature')
legend('Return WT', 'Supply WT', 'delta WT', 'Boiler SP')

subplot(2, 1, 2)
yyaxis left
plot(1:h, tin)
hold on
yyaxis right
ylim([-1 2])
plot(1:h, u_onoff, 'o-')
hold on
plot(1:h, occ_vector, 'm*--')
title('Tin / Boiler on&off signal / occupancy presence')
legend('Tin', 'Signal', 'Occ')








