clear all
close all
%generate random numbers with normal distribuiton

%large mean, stdev (20%)
lgsd = normrnd(4000, 800, [1,65536]);

%large mean, small sd (5%)
lgsd5 = normrnd(4000,200, [1,65536]);

%small mean, stdev (20%)
smsd = normrnd(700, 140,[1,65536]);

smsd5 = normrnd(700,35,[1,65536]);

histogram(lgsd,'FaceAlpha', 0.2,'EdgeAlpha',0.2)
hold on
histogram(smsd,'FaceAlpha', 0.5,'EdgeAlpha',0.2)
hold on
histogram(lgsd5,'FaceAlpha', 0.2,'EdgeAlpha',0.2)
hold on
histogram(smsd5,'FaceAlpha', 0.5,'EdgeAlpha',0.2)
xlabel('Simulated populations with large and small standard deviation')

CVlg = (std(lgsd)/mean(lgsd))*100

CVsm = (std(smsd)/mean(smsd))*100

CVlg5 = (std(lgsd5)/mean(lgsd5))*100

CVsm5 = (std(smsd5)/mean(smsd5))*100

CVlgsd = [CVlg, CVsm]
CVsmsd = [CVlg5,CVsm5]
meanlgsd = [mean(lgsd),mean(smsd)] 
meansmsd = [mean(lgsd5),mean(smsd5)]


figure()
scatter(meanlgsd,CVlgsd,'filled') 
hold on
scatter(meansmsd, CVsmsd,'filled')
xlabel('Distribution Mean')
ylabel('CV')
ylim([0 25])
xlim([0 5000])
legend('20% SD','5% SD')