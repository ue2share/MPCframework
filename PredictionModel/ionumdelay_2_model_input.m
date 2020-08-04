%%input : initial number of data set, duration of data set, 
%         number of input(double), number of output
function[X, Y, iddata_ar] = ionumdelay_2_model_input(input_num, output_num,...
    iodelay, codelay)

    global init_num duration t
    iodelay = iodelay-1;
    codelay = codelay-1;

    % input = signal + bsp + other else
    % codelay to control variable(signal and bsp)
    sig             = t(init_num-codelay:init_num+duration-1-codelay, 4);
    bsp                = t(init_num-codelay:init_num+duration-1-codelay, 11);
    
    % iodelay to input
    input_exceptsignal = t(init_num-iodelay:init_num+duration-1-iodelay, input_num);
    input_iddata_cell  = [sig bsp input_exceptsignal];
    X                  = table2array(input_iddata_cell);


    % output = depend on output number
    output_table       = t(init_num:init_num+duration-1, output_num);
    Y                  = table2array(output_table);

    
    % make iddata for armax
    iddata_ar       = iddata(Y, X);
    
end