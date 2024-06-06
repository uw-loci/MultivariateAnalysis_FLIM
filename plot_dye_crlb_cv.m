%%Plot coefficient of variance and CRLB data

%%add path to python script if needed as well as specify python env or 
% point to a conda env
addpath('H:\Projects\Fluorescein_Quenching\slimdata_analysis');
pyenv('Version','C:\Users\hwilson23\.conda\envs\naparienv\python.exe');

%load personal data to add to plot with crlb
data = load('H:\Projects\Fluorescein_Quenching\slimdata_analysis\datatable_CCVMeanandCV.mat');
meanlifetime = data.data.datatable(:,1);
CVoflifetime = data.data.datatable(:,2);

%specify parameters for crlb function tau (see python code for details)
lifetimes = linspace(0.1,5);
n = 2000;
T = 12.5;
b = 0.1;
crlb_result = [];

%call python code from matlab to get a crlb value for each lifetime
for i = 1:length(lifetimes)
    L = lifetimes(i);
    crlb = pyrunfile("crlb.py","crlb_return", L=L,n=n,b=b,T=T);
    crlb_result = [crlb_result, crlb];

end

%% plot data, must provide the lifetime values and CV data above to add to crlb plot
figure()
scatter(meanlifetime, CVoflifetime)
hold on
plot(lifetimes,sqrt(crlb_result)./lifetimes) %crlb is variance^2, so changing values to plot CV for crlb

title('crlb with CV data');
xlabel('Lifetime (ns)')
ylabel('Coefficient of Variation')
legend('CV experimental data', 'CV of CRLB');