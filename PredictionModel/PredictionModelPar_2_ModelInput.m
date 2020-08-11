%%input : initial number of data set, duration of data set, 
%         number of input(double), number of output
function[X, Y, iddata_ar] = PredictionModelPar_2_ModelInput(...
    t, startindex, duration, inputarray, output_num,...
    iodelay, codelay)

    iodelay = iodelay-1;
    codelay = codelay-1;

    
    % input = signal + bsp + other else
    % codelay to control variable(signal and bsp)
    sig             = t(startindex-codelay:startindex+duration-1-codelay, 4);
    bsp                = t(startindex-codelay:startindex+duration-1-codelay, 11);
    
    % iodelay to input=
    input_exceptsignal = t(startindex-iodelay:startindex+duration-1-iodelay, inputarray);
    input_iddata_cell  = [sig bsp input_exceptsignal];
    X                  = table2array(input_iddata_cell);


    % output = depend on output number
    output_table       = t(startindex:startindex+duration-1, output_num);
    Y                  = table2array(output_table);

    
    % make iddata for armax
    iddata_ar       = iddata(Y, X);
    
end