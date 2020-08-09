s1 = readtable('FloorHeating_occ1.xlsx', 'Range', 'B3:L52563');
% s2 = readtable('Radiator_occ3_strat2.xlsx', 'Range', 'B3:L52563');
% s3 = readtable('Radiator_occ3_strat3.xlsx', 'Range', 'B3:L52563');
% s4 = readtable('Radiator_occ3_strat4.xlsx', 'Range', 'B3:L52563');


% rt = {s1 s2 s3 s4};
rt = {s1};

for occstratnum = 1:1
 
rawtable = rt{occstratnum};
length_day = 144; %time resolution is 10min.

%preprocess data for winter data
length_Jan = 31*length_day;
length_Feb = 28*length_day;
length_Dec = 31*length_day;
length_Nov = 30*length_day;
length_Winter_first = length_Feb+length_Jan;
length_Winter_second = length_Dec+length_Nov;

t = [rawtable(end-length_Winter_second+1:end, :); rawtable(1:length_Winter_first, :)];
t.Properties.VariableNames = {'tin', 'tout', 'gas', 'signal', 'elec', 'rhin', 'rhout', 'occ', 'rwt', 'swt', 'bsp'};
t.delatT = t.swt - t.rwt;
rt{occstratnum} = t;
end

save('C:\MPCframework\PredictionModel\rt.mat')












