s = cell([22, 1]);
sumgas = zeros(23, 1);
comfort = zeros(23, 1);
sumgas(23) = 5514353;
comfort(23) = 884;

fnum = 8;
fname = sprintf('C:/MPCframework/Framework_in_TRNSYS/MPC_output/Strategy%d.xlsx', fnum);
s{fnum} = readtable(fname, 'Range','A3:F1011');
s{fnum}{:, 7}=abs(s{fnum}{:,5}-24);
s{fnum}{:, 8} = s{fnum}{:, 6}.*s{fnum}{:, 7};
sumgas(fnum) = sum(s{fnum}{:, 2});
comfort(fnum) = sum(s{fnum}{:, 8});