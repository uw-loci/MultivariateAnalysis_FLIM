%%Plot coefficient of variance and CRLB data

%%add path to python script if needed as well as specify python env or 
% point to a conda env
addpath('H:\firefox_downloads\');
pyenv('Version','C:\Users\hwilson23\.conda\envs\naparienv\python.exe');

%specify parameters for crlb function tau (see other code for detail)
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

%% plot data, must provide the lifetime values and CV data to add to crlb plot
data = load('H:\Projects\Fluorescein_Quenching\slimdata_analysis\datatable_CCVMeanandCV.mat');
meanlifetime = data.datatable(:,1);
CVoflifetime = data.datatable(:,2);


figure()
scatter(meanlifetime, CVoflifetime)
hold on
scatter(lifetimes,sqrt(crlb_result)./lifetimes) %crlb is variance^2, so changing values to plot CV for crlb

title('crlb with CV data');
xlabel('Lifetime (ns)')
ylabel('Coefficient of Variation')
legend('CV experimental data', 'CV of CRLB');