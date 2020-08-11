function[order_arx, order_armax] = order_4_ar_family(input_index, output_num, na, nb, nc)
    global inputset_total_tin inputset_total_gas inputset_total_delT
    
    switch output_num
        case 1
            input_num = inputset_total_tin{input_index};
        case 3
            input_num = inputset_total_gas{input_index};
        case 12
            input_num = inputset_total_delT{input_index};
    end
    
    nu = length(input_num)+2; %Don't forget signal and bsp
    ny = 1;
    
    na_mat = na*ones(ny, ny);
    nb_mat = nb*ones(ny, nu);
    nc_mat = nc*ones(ny, 1);
    nk = zeros(ny, nu);
   
    order_armax = [na_mat nb_mat nc_mat nk];
    order_arx = [na_mat nb_mat nk];
end
