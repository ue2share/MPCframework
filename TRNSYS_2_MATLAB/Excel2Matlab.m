
% TRNSYS output data's time resolution is 1min.
% s1 = readtable('FloorHeating_occ1.xlsx', 'Range', 'B3:L525603');
% s2 = readtable('FloorHeating_occ3_strat2.xlsx', 'Range', 'B3:L525603');
s3 = readtable('FloorHeating_occ3.xlsx', 'Range', 'B3:L525603');
% s4 = readtable('FloorHeating_occ3_strat4.xlsx', 'Range', 'B3:L525603');


% rt = {s1 s2 s3 s4};
rt = {s3};

for occstratnum = 1:1
 
rawtable = rt{occstratnum};
time_resolution = 60; %sec
length_day = (60*60*24)/time_resolution;

%preprocess data for winter data
length_Jan = 31*length_day;
length_Feb = 28*length_day;
length_Dec = 31*length_day;
length_Nov = 30*length_day;
length_Winter_first = length_Feb+length_Jan;
length_Winter_second = length_Dec+length_Nov;

t = [rawtable(end-length_Winter_second+1:end, :); rawtable(1:length_Winter_first, :)];
t.Properties.VariableNames = {'tin', 'tout', 'gas', 'signal', 'elec', 'rhin', 'rhout', 'occ', 'rwt', 'swt', 'bsp'};
t.deltaT = t.swt - t.rwt;

tsgroup = @(ts) 1:ts:172800;
rt{occstratnum} = t;


end

save('C:\MPCframework\PredictionModel\rt.mat')












