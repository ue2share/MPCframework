function [ output_args ] = InputIndex_2_InputArray( dependentVar_index, independentVar_index )
%UNTITLED3 Summary of this function goes here
%   Input number index to input number array
switch dependentVar_index
    case 1
        inputset_total_raw = [2 5 7 8];
        inputset_total = cell([15, 1]);
    case 3
        inputset_total_raw = [1 2 5 7 8];
         inputset_total = cell([31, 1]);
    case 12
        inputset_total_raw = [1 2 5 7 8];
         inputset_total = cell([31, 1]);
end

% Candidate sets for input number
% inputset_total = {};
i=0;
for n = 1:length(inputset_total_raw)

    s = nchoosek(inputset_total_raw, n);
    for m = 1:size(s)
        i=i+1;
       inputset_total{i} = s(m, :);
    end
    
end

output_args = inputset_total{independentVar_index};
end

