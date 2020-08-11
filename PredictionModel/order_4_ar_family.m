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
load dryer2;
z = iddata(y2,u2,0.08,'Tstart',0);
na = 2:4;
nc = 1:2;
nk = 0:2;
models = cell(18,5);
ct = 1;
for i = 1:3
    na_ = na(i);
    nb_ = na_;
    for j = 1:2
        nc_ = nc(j);
        for k = 1:3
            nk_ = nk(k); 
            [models{ct, :}] = deal(armax(z,[na_ nb_ nc_ nk_]), na_, nb_, nc_, nk_);
            ct = ct+1;
        end
    end
end


Above codes are from documentation of ARMAX. https://kr.mathworks.com/help/ident/ref/armax.html
I made some modifications to variable 'models'

In my problem, the number of parameters is much larger(e.g. na, nb, ..., nz), and their range is much broader.
I want to save all parameters(na, nb,..) and their output(like output of armax functin in above codes), which are heterogeneous.
Which data types are the most fit to contain these datasets? Cell? Table? other else?