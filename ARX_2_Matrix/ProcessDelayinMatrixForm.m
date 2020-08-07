%% Test with Tin
load tin_mdl_xy.mat

mdl = tin_arx_mdl{1, 1};
ord = tin_order_arx{1, 1};
X = tin_X{1, 1};
Y = tin_Y{1, 1};

%% Delay in model - Input Delay

% Delay 2 in first 3 elements, and delay 1 in last 3 elements.
idd = iddata(Y, X);
% arxopt = arxOptions('InputOffset', [2;2;2;1;1;1]);
mdl_delayInModel = arx(idd, ord, 'InputDelay', [2 2 2 1 1 1])


%% Delay in X - delte the delay term
X_delay = [X(1:4318, 1:3) X(2:4319, 4:6)];
idd_delay = iddata(Y(3:4320), X_delay);
mdl_delayInX = arx(idd_delay, ord)

%% Delay in X - delte the delay terms and substitute with 0
X_delay_sub0 = zeros(4320, 6);
X_delay_sub0(3:4320, 1:3) = X(1:4318, 1:3);
X_delay_sub0(2:4320, 4:6) = X(1:4319, 4:6);
idd_delay_sub0 = iddata(Y, X_delay_sub0);
mdl_delayInX_sub0 = arx(idd_delay_sub0, ord)