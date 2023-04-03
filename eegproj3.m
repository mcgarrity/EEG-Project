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
ylim([-1 1])

for e = 1:ELECTRODES
    subplot(16, 1, e)
    hold on
    area(data.timeline,(nounOtherPvals(e, :)<.05),'FaceColor','r')
    area(data.timeline,-(nounOwnPvals(e, :)<.05),'FaceColor','b')
    area(data.timeline,(otherOwnPvals(e, :)<.05)/2,'FaceColor','m')
    area(data.timeline,-(otherOwnPvals(e, :)<.05)/2,'FaceColor','m')
    ylabel(data.electrodeNames{e})
    set(gca,'xtick',[],'ytick',[])
end
sgtitle("2023/02/20 00:00")