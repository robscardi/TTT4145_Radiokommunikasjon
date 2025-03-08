clearvars -except Param
close all;
test = [3 -3]';
DUT = FramePreambleDetector(ThresholdMetric=15);
[y, type, started] = DUT(test);
