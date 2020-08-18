mFileErrorCode = 100;

nI = trnInfo(3);
nO = trnInfo(6);

if ( (trnInfo(7) == 0) & (trnTime-trnStartTime < 1e-6) )  
%% Load Prediction Model
    mFileErrorCode = 110;
    load MatlabController_Matrix_tin.mat
    load MatlabController_Matrix_gas.mat
    load MatlabController_Matrix_delT.mat
    
    load tin_inputnum.mat
    load gas_inputnum.mat
    load delT_inputnum.mat
    
    load tin_umxm.mat
    load gas_umxm.mat
    load delT_umxm.mat
    mFileErrorCode = 115;
%% Make Repository for saving data
    % If you want assign more value, preallocate large size matrix.
    ym_tin = zeros(100000,1);
    ym_gas = zeros(100000,1);
    ym_delT = zeros(100000,1);
    xm_tin = tin_um_xm_like_trnsys(:, 3:end);
    xm_gas = gas_um_xm_like_trnsys(:, 3:end);
    xm_delT = delT_um_xm_like_trnsys(:, 3:end);
    um = zeros(100000, 2);
    
%% Parameters for MPC
    ts_10min = 0;
    pmax = max([p_tin, p_gas, p_delT]);
    opt_strategy = 1;
    mFileErrorCode = 120;    % After initialization call
    
end

%% Run Matlab code only once in first iterative call.
if trnInfo(7) == 0 
    ts_10min = ts_10min+1;
end
%% Toss signal to TRNSYS
mFileErrorCode = 600;

trnOutputs(1) = xm_tin(ts_10min, 2);
trnOutputs(2) = xm_tin(ts_10min, 4);
mFileErrorCode = 0;
return









