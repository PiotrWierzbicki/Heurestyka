function [ idx, C ] = SBPPidx_d( y,slacomp,slacompb,cap,demand,noOfNodes )

%bCapMax=getUtil(slacomp); % tyle pasma na porotekcjê
bCapMax=cap; % 50-50 podzialu
bCap=zeros(size(bCapMax)); % na starcie wszystko wolne

% awaria: obydwie sciezki padniete lub zapas pelny
%zajmijmy sie zapasem
idx=zeros(size(y,1),length(slacomp));

t=y(:,1);
y=y(:,2:end);
failstate=zeros(size(demand));

C=zeros(size(y,1),size(bCap,1));

for eventId=1:size(y,1)
    for j=1:length(slacomp)
        %if sum(y(eventId,slacomp{j})) > 0 % jest awaria
        if any(y(eventId,slacomp{j})) % jest awaria
            %if sum(y(eventId,slacompb{j})) > 0 % awria w zapasie
            if any(y(eventId,slacompb{j}))
                idx(eventId,j)=1;
                %kasujemy przeplywy
                if failstate(j)==1
                    zapas = slacompb{j}-noOfNodes;
                    bCap(zapas)=bCap(zapas) - demand(j);
                    failstate(j)=0;

%                     zapas = slacompb{j}-noOfNodes;
%                     bCap(zapas)=0;
%                     failstate(j)=0;

                end
            else
                % sprawdzamy zajetosc zapasu
                % nowa zajetosc zapasu
                if failstate(j)==0
                    zapas = slacompb{j}-noOfNodes;
                    bCap(zapas)=bCap(zapas) + demand(j); %ok przy nieograniczonym zapasie
                    failstate(j)=1;
                end
%                 if sum(bCap > bCapMax) > 0 
%                     % gdzies jest przepelnienie
%                     % kasujemy sciezke i sygnal awarii
%                     bCap(zapas)=bCap(zapas) - demand(j);
%                     idx(eventId,j)=1;
%                     failstate(j)=0; %jednak nie idzie na zapasie
%                 end
            end
        else
            %dzial trasa podstawowa i wczesniej by zapas
            if failstate(j)==1
                zapas = slacompb{j}-noOfNodes;
                bCap(zapas)=bCap(zapas) - demand(j);
                failstate(j)=0;
            end
        end
        C(eventId,:)=bCap;
    end
end

end

