function [group] = group_data(basedata, start, length)
%==========================================================%
% Function's function
% Make group data like y_pk ; start from y(k) to y(k+p-1)
%----------------------------------------------------------%
% Input
% basedata : ym, um, xm --> measured data
%          : uc         --> calculated in optimization process
% start    : start index
% length   : length of array(# of timestep)
%----------------------------------------------------------%
% Output
% group    : if basedata is ym, [y(k); y(k+1); ... y(k+p-1)]
%          : if basedata is um, [u1(k); u2(k); u1(k+1); u2(k+1); ...u1(k+p-1); u2(k+p-1)]
%==========================================================%

[~, numdatatype] = size(basedata);
group = basedata(start:start+length-1, :);
group = group';
group = reshape(group, length*numdatatype, 1);

end