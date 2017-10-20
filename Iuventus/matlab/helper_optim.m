%clear
%clc

% load('optim-germanyi-sbpp5.mat');
% load('slacomp-germany.mat');

% load('optim-us-sbpp5.mat');
% load('slacomp-us.mat');

load(s1)
load(s2)

%%
X = cellfun(@(arg) arg*diag(demand),X,'UniformOutput',0);


%% remove routers
slacomp=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp,'UniformOutput', false);
slacomp2=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp2,'UniformOutput', false);

for i=1:length(alternativeslacomp)
    alternativeslacomp{i}=cellfun(@(arg) linksOnly(arg,noOfNodes),alternativeslacomp{i},'UniformOutput', false);
end

cap = zeros(size(cap)) + max(GetCapacity(slacomp,cap,demand,noOfNodes));


% for j=1:1
%     display(j)
%     r=rand(4,121);
% %      r = zeros(4,121);
% %      r(3,:)=1;
%     ProtVector = bsxfun(@eq,r,max(r));
%     C(j) = TotalCost(slacomp,slacomp2,alternativeslacomp,demand,ProtVector,cap(1));
% 
% 
%     %%
%     XT = zeros(100000,121);
% 
%     for i=1:121
%         tmp = ProtVector(:,i);
%         XT(:,i) = X{1,tmp}(:,i);
%     end
% 
%     alpha = 0.5;
%     varA(j) = quantile(sum(XT,2),alpha);
%     cvarA(j) = cVarNum(sum(XT,2),alpha);
% 
% end
