clear
clc

%load('Var_cptime_US_2_100.mat');

%RRiskMeasures = [{'Var'},{'cVar'},{'mean'}];
RRiskMeasures = [{'mean'}];
PPolicies = [{'cptime'},{'nfail'}];
NNets = [{'GER'}, {'US'}];

wweights = [2000, 4000, 8000, 16000, 32000; 8, 16, 32, 64, 128];

%dirr = '../OptimResults/wyniki_nowe_dobre_2/';
dirr = 'wyniki/Edge/';
dirr2 = 'wyniki/';
%%
for i1=1:1
    for i2=1:2
        for i3=1:2
            for i4=1:5

            RRiskMeasure = RRiskMeasures{i1};
            PPolicy = PPolicies{i2};
            NNet = NNets{i3};
            WWeight = num2str(wweights(i2,i4));
            
            load([dirr, 'Edge_', RRiskMeasure, '_', PPolicy, '_', NNet, '_4_', WWeight, '_1.mat' ]);
            load([dirr2, 'Black_', RRiskMeasure, '_', PPolicy, '_', NNet, '_1_', WWeight, '.mat' ]);
            %load('../OptimResults/Var_nfail_GER_3_10.mat');

            alphaV = 0.95;

            funs = [{@FitnessFun},{@FitnessFun2},{@FitnessFun3}];

            if strcmp(Net,'GER')
                CrashData='../symulacje/optim-germanyi-sbpp5.mat';
                NetData = '../sieci/slacomp-germany.mat';
            else
                CrashData='../symulacje/optim-us-sbpp5.mat';
                NetData = '../sieci/slacomp-us.mat';
            end

            s1 = CrashData;
            s2 = NetData;
            %%
%             load(CrashData);
%             load(NetData);
% 
%             X = cellfun(@(arg) arg*diag(demand),X,'UniformOutput',0);
% 
%             slacomp=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp,'UniformOutput', false);
%             slacomp2=cellfun(@(arg) linksOnly(arg,noOfNodes),slacomp2,'UniformOutput', false);
% 
%             for i=1:length(alternativeslacomp)
%                 alternativeslacomp{i}=cellfun(@(arg) linksOnly(arg,noOfNodes),alternativeslacomp{i},'UniformOutput', false);
%             end
% 
%             cap = zeros(size(cap)) + max(GetCapacity(slacomp,cap,demand,noOfNodes));
% 
%             Xcptime = cell2mat(X(1,:));
%             Xnfail = cell2mat(X(2,:));
% 
%             CovXcptime = cov(Xcptime);
%             CovXnfail = cov(Xnfail);
% 
%             MeanXcptime = mean(Xcptime);
%             MeanXnfail = mean(Xnfail);
% 
%             Data.slacomp = slacomp;
%             Data.slacomp2 = slacomp2;
%             Data.alternativeslacomp = alternativeslacomp;
%             Data.X = X;
%             Data.CovXcptime = CovXcptime;
%             Data.MeanXcptime = MeanXcptime;
%             Data.CovXnfail = CovXnfail;
%             Data.MeanXnfail = MeanXnfail;
%             Data.demand = demand;
%             Data.cap = cap;
%             Data.noOfNodes = noOfNodes;
% 
%             mm = size(slacomp,2);
% 
%             r0=zeros(4,mm);
%             r0(1,:) = 1;
%             P0.DNA = bsxfun(@eq,r0,max(r0));
%             [~, ~, R0] = FitnessFun(P0,Data,Weight,alphaV,0,Policy,RiskMeasure);
% 
% 
%             for i=1:4
%                 r = zeros(4,mm);
%                 r(i,:) = 1;
%                 Pop{i}.DNA = bsxfun(@eq,r,max(r));
%                 [Pop{i}.F, Pop{i}.C, Pop{i}.V] = funs{OptimF}(Pop{i},Data,Weight,alphaV,R0,Policy,RiskMeasure);
%                 CC1(i) = Pop{i}.C;
%                 VV1(i) = Pop{i}.V;
%             end

            %%
            plot(CC,VV, 'Color', [0.6 0.6 0.6], 'Marker', '+', 'LineStyle', 'none','MarkerSize',2);
            hold on
            
%             plot(CC0,VV0,'r.');
%             hold on
            
            C1 = NewPop{1}.C;
            V1 = NewPop{1}.V;
%            plot(NewPop{1}.C,NewPop{1}.V,'Color', [0 0 1], 'Marker', '.', 'LineStyle', 'none','MarkerSize',20);
            hold on
            line('Xdata',[CC1(1),VV1(1)],'YData',[VV1(1),CC1(1)])
            hold on
            line('Xdata',[0,3*10^8],'YData',[0, 3*10^8]);
            hold on

            load([dirr, 'Edge_', RRiskMeasure, '_', PPolicy, '_', NNet, '_4_', WWeight, '_2.mat' ]);
            plot(CC,VV, 'Color', [0.6 0.6 0.6], 'Marker', '+', 'LineStyle', 'none','MarkerSize',2);
            hold on
%             plot(CC0,VV0,'r.');
%             hold on
            C2 = NewPop{1}.C;
            V2 = NewPop{1}.V;
 %           plot(NewPop{1}.C,NewPop{1}.V,'Color', [0 1 0], 'Marker', '.', 'LineStyle', 'none','MarkerSize',20);
            hold on

            load([dirr, 'Edge_', RRiskMeasure, '_', PPolicy, '_', NNet, '_4_', WWeight, '_3.mat' ]);
            plot(CC,VV, 'Color', [0.6 0.6 0.6], 'Marker', '+', 'LineStyle', 'none','MarkerSize',2);
            C3 = NewPop{1}.C;
            V3 = NewPop{1}.V;
 %           plot(NewPop{1}.C,NewPop{1}.V,'Color', [1 0 0], 'Marker', '.', 'LineStyle', 'none','MarkerSize',20);
            hold on
            
%             plot(CC0,VV0,'r.');
%             hold on
            load([dirr, 'Edge_', RRiskMeasure, '_', PPolicy, '_', NNet, '_4_', WWeight, '_4.mat' ]);
            plot(CC,VV, 'Color', [0.6 0.6 0.6], 'Marker', '+', 'LineStyle', 'none','MarkerSize',2);
            hold on

            C4 = NewPop{1}.C;
            V4 = NewPop{1}.V;
 %           plot(NewPop{1}.C,NewPop{1}.V,'Color', [1 0 0], 'Marker', '.', 'LineStyle', 'none','MarkerSize',25);

%            plot(C1,V1,'Color', [1 0 0], 'Marker', '.', 'LineStyle', 'none','MarkerSize',25);
%            plot(C2,V2,'Color', [0 1 0], 'Marker', '.', 'LineStyle', 'none','MarkerSize',25);
%            plot(C3,V3,'Color', [1 0 1], 'Marker', '.', 'LineStyle', 'none','MarkerSize',25);
%            plot(C4,V4,'Color', [0 1 1], 'Marker', '.', 'LineStyle', 'none','MarkerSize',25);
     
            plot(CC1,VV1,'black.','MarkerSize',20);
            hold on

            ylim([0 1.01*max([VV VV1])])
            xlim([0 1.01*max([CC,CC1])])

            hold off
            sum(NewPop{1}.DNA')

            %%plot(minn)
            
            if(strcmp(RRiskMeasure,'Var'));
                RRRiskMeasure = 'VaR';
            elseif(strcmp(RRiskMeasure,'cVar'));
                RRRiskMeasure = 'cVaR';
            else
                RRRiskMeasure = 'RRiskMeasure';
            end
            
            ylabel(RRRiskMeasure);
            xlabel('Cost');
            print(['Figures/Edge_', RRiskMeasure, PPolicy, NNet, WWeight], '-dpng')
            end
        end
    end
end
