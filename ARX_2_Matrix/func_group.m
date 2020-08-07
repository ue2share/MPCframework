function [group] = func_group(basedata, k, length)
%==========================================================%
% Function's function
% Make group data like y_pk ; start from y(k) to y(k+p-1)
%----------------------------------------------------------%
% Input
% basedata : ym, um, xm --> measured data
%          : uc         --> calculated in optimization process
% k        : start index
% length   : length of array(# of timestep)
%----------------------------------------------------------%
% Output
% group    : if basedata is ym, [y(k); y(k+1); ... y(k+p-1)]
%          : if basedata is um, [u1(k); u2(k); u1(k+1); u2(k+1); ...u1(k+p-1); u2(k+p-1)]
%==========================================================%

global  q r ym_tin xm_tin um_tin ym_swt xm_swt um_swt ym_rwt xm_rwt um_rwt

if basedata == 'ym_tin'
    group = zeros(length, 1);    
    for i = 1:length
        group(i) = ym_tin(k-1+i, 1);
    end
    
elseif basedata =='ym_swt'
    group = zeros(length, 1);    
    for i = 1:length
        group(i) = ym_swt(k-1+i, 1);
    end
    
elseif basedata =='ym_rwt'
    group = zeros(length, 1);    
    for i = 1:length
        group(i) = ym_rwt(k-1+i, 1);
    end
    
elseif basedata == 'um_tin'
    group = zeros(length*r, 1);    
    for i = 1:length
        group(2*i-1, 1) = um_tin(k-1+i, 1);
        group(2*i, 1)   = um_tin(k-1+i, 2);
    end
    
    
elseif basedata == 'um_swt'
    group = zeros(length*r, 1);    
    for i = 1:length
        group(2*i-1, 1) = um_swt(k-1+i, 1);
        group(2*i, 1)   = um_swt(k-1+i, 2);
    end
    
elseif basedata == 'um_rwt'
    group = zeros(length*r, 1);    
    for i = 1:length
        group(2*i-1, 1) = um_rwt(k-1+i, 1);
        group(2*i, 1)   = um_rwt(k-1+i, 2);
    end
    
elseif basedata == 'xm_tin'
    group = zeros(length*(q-r), 1);    
    for i = 1:length
        group(4*i-3, 1) = xm_tin(k-1+i, 1);
        group(4*i-2, 1) = xm_tin(k-1+i, 2);
        group(4*i-1, 1) = xm_tin(k-1+i, 3);
        group(4*i, 1)   = xm_tin(k-1+i, 4);
    end
    
elseif basedata == 'xm_swt'
    group = zeros(length*(q-r), 1);    
    for i = 1:length
        group(4*i-3, 1) = xm_swt(k-1+i, 1);
        group(4*i-2, 1) = xm_swt(k-1+i, 2);
        group(4*i-1, 1) = xm_swt(k-1+i, 3);
        group(4*i, 1)   = xm_swt(k-1+i, 4);
    end
    
elseif basedata == 'xm_rwt'
    group = zeros(length*(q-r), 1);    
    for i = 1:length
        group(4*i-3, 1) = xm_rwt(k-1+i, 1);
        group(4*i-2, 1) = xm_rwt(k-1+i, 2);
        group(4*i-1, 1) = xm_rwt(k-1+i, 3);
        group(4*i, 1)   = xm_rwt(k-1+i, 4);
    end
end

end