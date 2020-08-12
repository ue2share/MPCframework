function[order_arx, order_armax] = order_4_ar_family(inputarray, na, nb, nc)
    
    nu = length(inputarray)+2; %Don't forget signal and bsp
    ny = 1;
    
    na_mat = na*ones(ny, ny);
    nb_mat = nb*ones(ny, nu);
    nc_mat = nc*ones(ny, 1);
    nk = zeros(ny, nu);
   
    order_armax = [na_mat nb_mat nc_mat nk];
    order_arx = [na_mat nb_mat nk];
end
