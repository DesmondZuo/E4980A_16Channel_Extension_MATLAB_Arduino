Pre_filter = [VarName1, VarName2, VarName3, VarName4, VarName5, VarName6, VarName7, VarName8, VarName9];
CG = Pre_filter;
CoefG = [0, 0, 0, 0, 0, 0, 0, 0, 0];

for i = 1:9
    this_calibrate = CG(:, i);
    this_mean = mean(this_calibrate);
    this_max = max(this_calibrate);
    CoefG(i) = 1/(this_max - this_mean);
    end2



