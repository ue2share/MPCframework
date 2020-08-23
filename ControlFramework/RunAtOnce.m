clear all


TestingArray = zeros(22, 4);
TestingArray(1, :) = [1 1 5 36];
TestingArray(2, :) = [1 2 5 36];
TestingArray(3, :) = [1 5 5 36];
TestingArray(4, :) = [1 6 5 36];
TestingArray(5, :) = [1 11 5 36];
TestingArray(6, :) = [1 13 5 36];
TestingArray(7, :) = [1 15 5 36];

TestingArray(8, :) = [3 1 5 36];
TestingArray(9, :) = [3 11 5 36];
TestingArray(10, :) = [3 20 5 36];
TestingArray(11, :) = [3 30 5 36];
TestingArray(12, :) = [3 31 5 36];

TestingArray(13, :) = [1 15 3 36];
TestingArray(14, :) = [1 15 10 36];
TestingArray(15, :) = [3 31 3 36];
TestingArray(16, :) = [3 31 10 36];

TestingArray(17, :) = [1 15 5 6];
TestingArray(18, :) = [1 15 5 18];
TestingArray(19, :) = [1 15 5 72];
TestingArray(20, :) = [3 31 5 6];
TestingArray(21, :) = [3 31 5 18];
TestingArray(22, :) = [3 31 5 72];

ind = 1;
dependentvar_index = TestingArray(ind, 1);               %Tin : 1, Gas : 3, delT : 12
indepedentvar_index = TestingArray(ind, 2);
na = TestingArray(ind, 3);
nb = na;
nc = na;
phzn = TestingArray(ind, 4);


run 'C:\MPCframework\PredictionModel\CalcPredictionModel.m'
run 'C:\MPCframework\ARX_2_Matrix\Run_All_ARX_2_MatrixForm.m'