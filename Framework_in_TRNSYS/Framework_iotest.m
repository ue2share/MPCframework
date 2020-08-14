


% trnInfo = zeros(10, 1);
% trnTime = 10;
% trnStartTime = 10;
% trnInputs = 1:11;
% trnOutputs = 1:8;
% trnTimeStep = 1;
% mFileErrorCode = 100;



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

%% Make Repository for saving data
    % If you want assign more value, preallocate large size matrix.
    ym_tin = zeros(1000,1);
    ym_gas = zeros(1000,1);
    ym_delT = zeros(1000,1);
    xm_tin = zeros(1000,length(tin_inputnum));
    xm_gas = zeros(1000,length(gas_inputnum));
    xm_delT = zeros(1000,length(delT_inputnum));
    um = zeros(1000, 2);
    
    
    ts_5min = 0;
    pmax = max([p_tin, p_gas, p_delT]);
    mFileErrorCode = 120;    % After initialization call
    
end

%% Run Matlab code only once in first iterative call.
if trnInfo(7) == 0 
mFileErrorCode = 125;
%% Change time parameters's unit from hour to minute.
trnTime_2_min = round(trnTime*60);
trnStartTime_2_min = round(trnStartTime*60);
trnTimeStep_2_min = round(trnTimeStep*60);
mFileErrorCode = 128;

%% Run matlab code when model timestep is according with TRNSYS timestep.
if mod((trnTime_2_min-trnStartTime_2_min)/trnTimeStep_2_min, 5)==0
    

    %% Get IEQ values from TRNSYS
    mFileErrorCode = 130;
    ts_5min = ts_5min+1;
    
    ym_tin(ts_5min, 1) = trnInputs(1);
    ym_gas(ts_5min, 1) = trnInputs(3);
    ym_delT(ts_5min, 1) = trnInputs(10)-trnInputs(9);
    xm_tin(ts_5min, :) = trnInputs(tin_inputnum);
    xm_gas(ts_5min, :) = trnInputs(gas_inputnum);
    xm_delT(ts_5min, :) = trnInputs(delT_inputnum);
   
    mFileErrorCode = 135;
    if ts_5min<pmax & ym_tin(ts_5min, 1)<24
        um(ts_5min, 1) = 1;
        um(ts_5min, 2) = 60;
    elseif ts_5min<pmax & ym_tin(ts_5min, 1)>=24
        um(ts_5min, 1) = 0;
        um(ts_5min, 2) = 60;
    else
        if ts_5min==pmax
            um(ts_5min, 1) = 1;
            um(ts_5min, 2) = 60;
        end
        um(ts_5min+1, 1) = ym_tin(ts_5min, 1);
        um(ts_5min+1, 2) = ym_tin(ts_5min, 1)*100;
    end
    
    
    mFileErrorCode = 140;
end
end
%% Toss signal to TRNSYS
mFileErrorCode = 300;

trnOutputs(1) = um(ts_5min, 1);
trnOutputs(2) = um(ts_5min, 2);

mFileErrorCode = 0;
return









