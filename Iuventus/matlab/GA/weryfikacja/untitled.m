load BestConf.mat
for i=1:1
    file=[num2str(i),'.txt'];
    %data=importdata(file);
    lbl=importdata([file,'.lbl']);
    idx = cellfun(@(arg) strcmp(arg,'UnprotectedAvail'),lbl)';
    X=data(:,idx);
    XT = sum(X');
end

alpha = 0.95;

VaR = quantile(XT,alpha);
CVaR = cVarNum(XT,alpha);
RiskExposure = mean(XT);