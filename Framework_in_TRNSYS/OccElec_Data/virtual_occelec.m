load UltimateData1.txt

UltimateData0 = [UltimateData1(42:end, :); UltimateData1(1:41, :)];

save('UltimateData0.txt', 'UltimateData0', '-ascii')
