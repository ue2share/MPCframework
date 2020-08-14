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

%% Make Repository for saving data
    % If you want assign more value, preallocate large size matrix.
    ym_tin = zeros(1000,1);
    ym_gas = zeros(1000,1);
    ym_delT = zeros(1000,1);
    xm_tin = zeros(1000,length(tin_inputnum));
    xm_gas = zeros(1000,length(gas_inputnum));
    xm_delT = zeros(1000,length(delT_inputnum));
    um = zeros(1000, 2);
    
%% Parameters for MPC
    ts_5min = 0;
    pmax = max([p_tin, p_gas, p_delT]);
    opt_strategy = 1;
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
    
    %% Transfer manual signal when there are not enough value in ym, xm to optimization.
    mFileErrorCode = 135;
    if ts_5min<pmax & ym_tin(ts_5min, 1)<24
        um(ts_5min, 1) = 1;
        um(ts_5min, 2) = 60;
    elseif ts_5min<pmax & ym_tin(ts_5min, 1)>=24
        um(ts_5min, 1) = 0;
        um(ts_5min, 2) = 60;
    elseif ts_5min>=pmax % When there are enough value to optimization
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
mFileErrorCode = 300;                    
            %% Inequality constraints - Tin
            % 22<=[R1 R2]*[u1 u2]' + S_tin<=26

            % Calculating S_tin 
            u_tin_past_group = group_data(um, ts_5min-p_tin+2, p_tin-1); 
            x_tin_group = group_data(xm_tin, ts_5min-p_tin+2, p_tin+h_tin-1);
mFileErrorCode = 310;    
            V_tin = zeros(h, 1);
            y_tin_past = group_data(ym_tin, ts_5min-p_tin+1, p_tin);
            for n = 1:h
            V_tin(n) = A_tin*C_tin^(n-1)*y_tin_past;
            end
mFileErrorCode = 320;                
            S_tin = T1_tin*u_tin_past_group + U_tin*x_tin_group + V_tin;

            % Set A and b
            tin_lb = 24;
            tin_ub = 52;
            A = [R1_tin R2_tin];
            b = tin_ub-S_tin;
            A = [A;-A];
            b_lb = tin_lb-S_tin;
            b = [b;-b_lb];
mFileErrorCode = 330;    
            %% Objective function
            f = [R1_gas R2_gas];
            f = sum(f);
mFileErrorCode = 400;            
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
mFileErrorCode = 500;
    %% Save signal in um
            if ts_5min==pmax
                um(ts_5min, 1) = signal_in_tp1;
                um(ts_5min, 2) = bsp_in_tp1;
            end
            um(ts_5min+1, 1) = signal_in_tp1;
            um(ts_5min+1, 2) = bsp_in_tp1;
            end
    end
    
    
    mFileErrorCode = 500;

end
end
%% Toss signal to TRNSYS
mFileErrorCode = 600;

trnOutputs(1) = um(ts_5min, 1);
trnOutputs(2) = um(ts_5min, 2);

mFileErrorCode = 0;
return









