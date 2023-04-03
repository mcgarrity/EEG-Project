load("202302200000_Mon1.mat")

TIMEPOINTS = 256;
ELECTRODES = 16;

%Own vs Noun
nounOwnPvals = zeros(ELECTRODES, TIMEPOINTS);
nounOtherPvals = zeros(ELECTRODES, TIMEPOINTS);
otherOwnPvals = zeros(ELECTRODES, TIMEPOINTS);


for e = 1:ELECTRODES
    for t = 1:TIMEPOINTS
        [nOwnSignificant, nOwnPvalue] = ttest2(data.Own(e, :, t), data.Noun(e, :, t));
        nounOwnPvals(e, t) = nOwnPvalue;
        [nOthsignificant, nOthPvalue] = ttest2(data.Other(e, :, t), data.Noun(e, :, t));
        nounOtherPvals(e, t) = nOthPvalue;
        [othOwnsignificant, othOwnPvalue] = ttest2(data.Other(e, :, t), data.Own(e, :, t));
        otherOwnPvals(e, t) = othOwnPvalue;
    end    
end

nounOwnSig = 100*(nounOwnPvals<.05);
nounOtherSig = 100*(nounOtherPvals<.05);
otherOwnSig = 100*(otherOwnPvals<.05);

ELECTRODE = 9;

figure
hold on
plot(data.timeline, nounOwnSig(ELECTRODE, :))
plot(data.timeline, mean(squeeze(data.Own(ELECTRODE, :, :))))
plot(data.timeline, mean(squeeze(data.Noun(ELECTRODE, :, :))))
title("Own vs Noun " + data.electrodeNames{ELECTRODE} + " Electrode")

%Other vs Noun

figure
hold on
plot(data.timeline, nounOtherSig(ELECTRODE, :))
plot(data.timeline, mean(squeeze(data.Own(ELECTRODE, :, :))))
plot(data.timeline, mean(squeeze(data.Noun(ELECTRODE, :, :))))
title("Other vs Noun " + data.electrodeNames{ELECTRODE} + " Electrode")

%Other vs Own

figure
hold on
plot(data.timeline, otherOwnSig(ELECTRODE, :))
plot(data.timeline, mean(squeeze(data.Own(ELECTRODE, :, :))))
plot(data.timeline, mean(squeeze(data.Noun(ELECTRODE, :, :))))
title("Other vs Own " + data.electrodeNames{ELECTRODE} + " Electrode")


figure
hold on
ylim([-1.5 1.5])

area(data.timeline,(nounOtherPvals(ELECTRODE, :)<.05),'FaceColor','r')
area(data.timeline,-(nounOwnPvals(ELECTRODE, :)<.05),'FaceColor','b')
area(data.timeline,(otherOwnPvals(ELECTRODE, :)<.05)/2,'FaceColor','m')
area(data.timeline,-(otherOwnPvals(ELECTRODE, :)<.05)/2,'FaceColor','m')


