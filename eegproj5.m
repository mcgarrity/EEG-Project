clear all
filenames = ["202302200000_Mon1.mat", "202302201427_Mon1.mat", "202302271521_MonA.mat", "202303271412_MonA.mat"];

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
[ELECTRODES, nounTrials, TIMEPOINTS] = size(Noun_data);

nounMean = squeeze(mean(mean(Noun_data, 2)));
nounBadTrials = [];

for t = 1:nounTrials
    if immse(nounMean, squeeze(mean(Noun_data(:, t, :)))) > 0.25
        nounBadTrials = [nounBadTrials, t];
    end
end

disp(nounBadTrials)
Noun_data(:, nounBadTrials, :) = [];

%Get rid of bad noun trials
[ELECTRODES, nounTrials, TIMEPOINTS] = size(Noun_data);

nounMean = squeeze(mean(mean(Noun_data, 2)));
nounBadTrials = [];

for t = 1:nounTrials
    if immse(nounMean, squeeze(mean(Noun_data(:, t, :)))) > 0.2
        nounBadTrials = [nounBadTrials, t];
    end
end

disp(nounBadTrials)
Noun_data(:, nounBadTrials, :) = [];


%Get rid of bad other trials
[ELECTRODES, otherTrials, TIMEPOINTS] = size(Other_data);

otherMean = squeeze(mean(mean(Other_data, 2)));
otherBadTrials = [];

for t = 1:otherTrials
    if immse(otherMean, squeeze(mean(Other_data(:, t, :)))) > 0.2
        otherBadTrials = [otherBadTrials, t];
    end
end

Other_data(:, otherBadTrials, :) = [];


%Get rid of bad own trials
[ELECTRODES, ownTrials, TIMEPOINTS] = size(Own_data);

ownMean = squeeze(mean(mean(Own_data, 2)));
ownBadTrials = [];

for t = 1:ownTrials
    if immse(ownMean, squeeze(mean(Own_data(:, t, :)))) > 0.2
        ownBadTrials = [ownBadTrials, t];
    end
end

disp(ownBadTrials)
Own_data(:, ownBadTrials, :) = [];



%Plot average signal at each electrode for all 3 conditions
figure
for e = 1:ELECTRODES
    subplot(4, 4, e)
    hold on
    plot(data.timeline, smooth(mean(squeeze(Noun_data(e, :, :)))), 'k')
    plot(data.timeline, smooth(mean(squeeze(Own_data(e, :, :)))), 'b')
    plot(data.timeline, smooth(mean(squeeze(Other_data(e, :, :)))), 'r')
    title("Electrode " + data.electrodeNames{e})
end
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

legend('Other vs Noun', 'Own vs Noun', 'Other vs Own')
