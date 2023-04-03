load("202302200000_Mon1.mat")

TIMEPOINTS = 256;
ELECTRODE = 9;


%Own vs Noun
nounOwnPvals = zeros(1, TIMEPOINTS);

for t = 1:TIMEPOINTS
    [significant, pvalue] = ttest2(data.Own(ELECTRODE, :, t), data.Noun(ELECTRODE, :, t));
    nounOwnPvals(1, t) = pvalue;
end    

nounOwnSig = 100*(nounOwnPvals<.05);

figure
hold on
plot(data.timeline, nounOwnSig)
plot(data.timeline, mean(squeeze(data.Own(5, :, :))))
plot(data.timeline, mean(squeeze(data.Noun(5, :, :))))
title("Own vs Noun " + data.electrodeNames{ELECTRODE} + " Electrode")

%Other vs Noun
nounOtherPvals = zeros(1, TIMEPOINTS);

for t = 1:TIMEPOINTS
    [significant, pvalue] = ttest2(data.Other(ELECTRODE, :, t), data.Noun(ELECTRODE, :, t));
    nounOtherPvals(1, t) = pvalue;
end    

nounOtherSig = 100*(nounOtherPvals<.05);

figure
hold on
plot(data.timeline, nounOtherSig)
plot(data.timeline, mean(squeeze(data.Own(5, :, :))))
plot(data.timeline, mean(squeeze(data.Noun(5, :, :))))
title("Other vs Noun " + data.electrodeNames{ELECTRODE} + " Electrode")

%Other vs Own
otherOwnPvals = zeros(1, TIMEPOINTS);

for t = 1:TIMEPOINTS
    [significant, pvalue] = ttest2(data.Other(ELECTRODE, :, t), data.Own(ELECTRODE, :, t));
    otherOwnPvals(1, t) = pvalue;
end    

otherOwnSig = 100*(otherOwnPvals<.05);

figure
hold on
plot(data.timeline, otherOwnSig)
plot(data.timeline, mean(squeeze(data.Own(5, :, :))))
plot(data.timeline, mean(squeeze(data.Noun(5, :, :))))
title("Other vs Own " + data.electrodeNames{ELECTRODE} + " Electrode")


figure
hold on
ylim([-1.5 1.5])

area(data.timeline,(nounOtherPvals(:)<.05),'FaceColor','r')
area(data.timeline,-(nounOwnPvals(:)<.05),'FaceColor','b')
area(data.timeline,(otherOwnPvals(:)<.05)/2,'FaceColor','m')
area(data.timeline,-(otherOwnPvals(:)<.05)/2,'FaceColor','m')


