%%Plot coefficient of variance and CRLB data

%%add path to python script if needed as well as specify python env or 
% point to a conda env
addpath('H:\Projects\Fluorescein_Quenching\slimdata_analysis');
pyenv('Version','C:\Users\hwilson23\.conda\envs\naparienv\python.exe');

%load personal data to add to plot with crlb
data = load('H:\Projects\Fluorescein_Quenching\slimdata_analysis\datatable_CCVMeanandCV.mat');
meanlifetime = data.data.datatable(:,1);
CVoflifetime = data.data.datatable(:,2);
photonsdata = data.data.datatable(:,3);

%specify parameters for crlb function tau (see python code for details)
lifetimes = linspace(0.5,5,20);
%n = 2000;
n = linspace(500,4000,20);
T = 12.5;
b = 0.1;
crlb_result = [];


for j = 1:length(n)

    %call python code from matlab to get a crlb value for each lifetime
    for i = 1:length(lifetimes)

        L = lifetimes(i);
        crlb = pyrunfile("crlb.py","crlb_return", L=L,n=n(j),b=b,T=T);
        crlb_result(j,i) = crlb;
    
    end
   
end

%% plot data, must provide the lifetime values and CV data above to add to crlb plot
figure()
subplot(2,2,[1,2]);
scatter3(meanlifetime,photonsdata, CVoflifetime)
hold on

surf(lifetimes,n,sqrt(crlb_result)./lifetimes, 'FaceAlpha',0.5) %crlb is variance, so changing values to plot CV for crlb
hold on
scatter3(1.692,1752,.031)

title('crlb with CV data');
xlabel('Lifetime (ns)')
ylabel('Photons')
zlabel('CV of CRLB')
legend('CV Dye Data', 'CV of CRLB','CV Single Cell');
zlim([0,0.25])
xlim([0 6])
ylim([0 4000])

subplot(2,2,3)
scatter(meanlifetime,CVoflifetime)
xlabel('Lifetime (ns)')
ylabel('CV')
hold on
scatter(1.692, 0.031)

subplot(2,2,4)
scatter(photonsdata, CVoflifetime)
xlabel('Photons')
ylabel('CV')
hold on
scatter(1752,0.031)

