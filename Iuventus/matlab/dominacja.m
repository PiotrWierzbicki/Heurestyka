N=200;
data=randn(N,2);

%% szybkie ale tylko dla ma³ych N
tic
%d=sum(bsxfun(@gt,data(:,1),data(:,1)') & bsxfun(@gt,data(:,2),data(:,2)'),2);
toc

%% Troche wolniejsze ale bez ograniczen na N GPU
N=40000;
data=randn(N,2);
d2=zeros(N,1);
tic
for i=1:N
    d2(i)= sum(all(bsxfun(@lt,data,data(i,:)),2));
end
toc
%% plot
plot(data(:,1),data(:,2),'b.');
hold on
plot(data(d2==0,1),data(d2==0,2),'ro');
plot(data(d2 < 1,1),data(d2 < 1,2),'ro');
hold off

return
%% Troche wolniejsze ale bez ograniczen na N GPU
N=20000;
data=randn(N,2);
data= gpuArray(data);
d2=gpuArray(zeros(N,1));
tic
for i=1:N
    %d2(i)=
    sum(all(bsxfun(@lt,data,data(i,:)),2));
end
toc

%%

tic
ff = find_pareto_frontier(data);
toc