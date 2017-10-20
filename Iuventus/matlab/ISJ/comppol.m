function [ m1,vm ] = comppol( T,r,Pingrupa,compensation,varargin )
%comppol compensation policy

switch compensation
    case 'avail'
        m1=full(Pingrupa*(sum(T^2\r,2)));
        m2=full(Pingrupa*(-2*sum(T^3\r,2)));
        vm=m2-m1^2;
    case 'snowball'
        %m1=full(Pingrupa*(-2*sum(T^3\r,2)))/varargin{1}{1};
        m1=full(Pingrupa*(-2*sum(T^3\r,2)));
        m2=full(Pingrupa*(-24*sum(T^5\r,2)));
        vm=(m2-m1^2)/varargin{1}{1}^2;
        m1=m1/varargin{1}{1};
    case 'cont'
        m1=1;
        m2=1;
        vm=m2-m1^2;
    case 'fixedrestart'
        m1=full(Pingrupa*(sum(T^2\r,2))) ;
        m2=full(Pingrupa*(-2*sum(T^3\r,2)));
        vm=m2-m1^2;
        m1=m1+ varargin{1}{1};
end

end

