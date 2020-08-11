%%input : initial number of data set, duration of data set, 
%         number of input(double), number of output
function[X, Y, iddata_ar] = ionumdelay_2_model_input(input_index, output_num,...
    iodelay, codelay)

    global t startindex duration inputset_total_tin inputset_total_gas inputset_total_delT
    iodelay = iodelay-1;
    codelay = codelay-1;

    switch output_num
        case 1
            input_num = inputset_total_tin{input_index};
        case 3
            input_num = inputset_total_gas{input_index};
        case 12
            input_num = inputset_total_delT{input_index};
    end
    
    % input = signal + bsp + other else
    % codelay to control variable(signal and bsp)
    sig             = t(startindex-codelay:startindex+duration-1-codelay, 4);
    bsp                = t(startindex-codelay:startindex+duration-1-codelay, 11);
    
    % iodelay to input=
    input_exceptsignal = t(startindex-iodelay:startindex+duration-1-iodelay, input_num);
    input_iddata_cell  = [sig bsp input_exceptsignal];
    X                  = table2array(input_iddata_cell);


    % output = depend on output number
    output_table       = t(startindex:startindex+duration-1, output_num);
    Y                  = table2array(output_table);

    
    % make iddata for armax
    iddata_ar       = iddata(Y, X);
    
end