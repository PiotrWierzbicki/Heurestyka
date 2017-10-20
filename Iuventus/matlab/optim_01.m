load('optim-germanyi-sbpp22.mat');
%%

XT = zeros(100000,121);

%%
for i=1:121
    tmp = ProtVector(:,i);
    XT(:,i) = X{1,tmp}(:,i);
end

%%
alpha = 0.95;
varA = quantile(sum(XT,2),alpha)
cvarA = cVarNum(sum(XT,2),0.95);