clear all
filenames = ["202302200000_Mon1.mat", "202302201427_Mon1.mat", "202302271521_MonA.mat", "202302270552_MonA.mat", "202303271349_MonA.mat", "202303271412_MonA.mat"];

Noun_data = [];
Own_data = [];
Other_data = [];

for name = filenames
    data = importdata(name);
    NounNormData = data.Noun./max(data.Noun, [], 3);
    Noun_data = cat(2, Noun_data,NounNormData);
    
    OwnNormData = data.Own./max(data.Own, [], 3);
    Own_data = cat(2, Own_data,OwnNormData);
    
    OtherNormData = data.Other./max(data.Other, [], 3);
    Other_data = cat(2, Other_data,OtherNormData);
end    


%Get rid of bad noun trials
[~, nounTrials, ~] = size(Noun_data);

nounBadTrials = [];

for t = 1:nounTrials
    if std(squeeze(mean(Noun_data(:, t, :)))) > 0.5
        nounBadTrials = [nounBadTrials, t];
    end
end

Noun_data(:, nounBadTrials, :) = [];


%Get rid of bad other trials
[~, otherTrials, ~] = size(Other_data);

otherBadTrials = [];

for t = 1:otherTrials
    if std(squeeze(mean(Other_data(:, t, :)))) > 0.5
        otherBadTrials = [otherBadTrials, t];
    end
end

Other_data(:, otherBadTrials, :) = [];


%Get rid of bad own trials
[ELECTRODES, ownTrials, TIMEPOINTS] = size(Own_data);

ownBadTrials = [];

for t = 1:ownTrials
    if std(squeeze(mean(Own_data(:, t, :)))) > 0.5
        ownBadTrials = [ownBadTrials, t];
    end
end

Own_data(:, ownBadTrials, :) = [];

%Get rid of bad electrodes
Noun_data(11, :, :) = [];
Own_data(11, :, :) = [];
Other_data(11, :, :) = [];
data.electrodeNames(11) = [];
ELECTRODES = ELECTRODES-1;

%Plot average signal at each electrode for all 3 conditions
figure('Color','white')


subplot(4, 4, 1)
hold on
plot(data.timeline, smooth(mean(squeeze(Noun_data(1, :, :)))), 'k')
plot(data.timeline, smooth(mean(squeeze(Own_data(1, :, :)))), 'b')
plot(data.timeline, smooth(mean(squeeze(Other_data(1, :, :)))), 'r')
title("Electrode " + data.electrodeNames{1})
xlabel('Time (s)'); ylabel('EEG Signal (µV)')

for e = 2:ELECTRODES
    subplot(4, 4, e)
    hold on
    plot(data.timeline, smooth(mean(squeeze(Noun_data(e, :, :)))), 'k')
    plot(data.timeline, smooth(mean(squeeze(Own_data(e, :, :)))), 'b')
    plot(data.timeline, smooth(mean(squeeze(Other_data(e, :, :)))), 'r')
    title("Electrode " + data.electrodeNames{e})
    set(gca,'xtick',[],'ytick',[])

end
sgtitle('Averaged EEG Waveforms')
legend('Noun', 'Own', 'Other')

%Find significant periods
nounOwnPvals = zeros(ELECTRODES, TIMEPOINTS);
nounOtherPvals = zeros(ELECTRODES, TIMEPOINTS);
otherOwnPvals = zeros(ELECTRODES, TIMEPOINTS);

for e = 1:ELECTRODES
    for t = 1:TIMEPOINTS
        [nOwnSignificant, nOwnPvalue] = ttest2(Own_data(e, :, t), Noun_data(e, :, t));
        nounOwnPvals(e, t) = nOwnPvalue;
        [nOthsignificant, nOthPvalue] = ttest2(Other_data(e, :, t), Noun_data(e, :, t));
        nounOtherPvals(e, t) = nOthPvalue;
        [othOwnsignificant, othOwnPvalue] = ttest2(Other_data(e, :, t), Own_data(e, :, t));
        otherOwnPvals(e, t) = othOwnPvalue;
    end    
end


figure('Color','white')
hold on
ylim([-1 1])

for e = 1:ELECTRODES-1
    subplot(15, 1, e)
    hold on
    area(data.timeline,(nounOtherPvals(e, :)<.05),'FaceColor','r')
    area(data.timeline,-(nounOwnPvals(e, :)<.05),'FaceColor','b')
    area(data.timeline,(otherOwnPvals(e, :)<.05)/2,'FaceColor','m')
    area(data.timeline,-(otherOwnPvals(e, :)<.05)/2,'FaceColor','m')
    ylabel(data.electrodeNames{e})
    set(gca,'xtick',[],'ytick',[])
end

subplot(15, 1, 15)
hold on
area(data.timeline,(nounOtherPvals(15, :)<.05),'FaceColor','r')
area(data.timeline,-(nounOwnPvals(15, :)<.05),'FaceColor','b')
area(data.timeline,(otherOwnPvals(15, :)<.05)/2,'FaceColor','m')
area(data.timeline,-(otherOwnPvals(15, :)<.05)/2,'FaceColor','m')
set(gca,'ytick',[])
xlabel('Time (s)')

ylabel(data.electrodeNames{15})

sgtitle("Significant Differences in EEG Signal")

legend('Other vs Noun', 'Own vs Noun', 'Other vs Own')
