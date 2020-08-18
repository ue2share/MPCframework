
% TRNSYS output data's time resolution is 1min.
s1 = readtable('FloorHeating_occ1.xlsx', 'Range', 'B3:L525603');
% s2 = readtable('FloorHeating_occ3_strat2.xlsx', 'Range', 'B3:L525603');
% s3 = readtable('FloorHeating_occ3.xlsx', 'Range', 'B3:L525603');
% s4 = readtable('FloorHeating_occ3_strat4.xlsx', 'Range', 'B3:L525603');


% rt = {s1 s2 s3 s4};
rt = {s1};

for occstratnum = 1:1
 
rawtable = rt{occstratnum};
time_resolution = 60; %sec
length_day = (60*60*24)/time_resolution;

%preprocess data for winter data
length_Nov = 30*length_day;
length_Dec = 31*length_day;
length_NovDec = length_Nov+length_Dec;
t_1112 = rawtable(end-length_NovDec+1:end, :);

length_Jan = 31*length_day;
length_Feb = 28*length_day;
length_JanFeb = length_Feb+length_Jan;
t_12 = rawtable(1:length_JanFeb, :);

t = [t_1112; t_12];
t.Properties.VariableNames = {'tin', 'tout', 'gas', 'signal', 'elec', 'rhin', 'rhout', 'occ', 'rwt', 'swt', 'bsp'};
t.deltaT = t.swt - t.rwt;

rt{occstratnum} = t;


end

save('C:\MPCframework\PredictionModel\rt.mat')












