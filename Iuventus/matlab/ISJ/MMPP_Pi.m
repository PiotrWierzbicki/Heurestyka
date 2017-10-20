function y=MMPP_Pi(Q)
m=size(Q);
m=m(1);

qx=Q;
qx(:,m)=ones(m,1);
wynik=zeros(1,m);
wynik(m)=1;
y=wynik/qx;

end