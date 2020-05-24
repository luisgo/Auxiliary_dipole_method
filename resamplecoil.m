function [raux,kaux]=resamplecoil(rs,ks,N,Nj)
X=rs(1,:,:); Y=rs(2,:,:);Z=rs(3,:,:);
Xp=0.00*(max(X(:))-min(X(:)));
Yp=0.00*(max(Y(:))-min(Y(:)));
Zp=6.127016653792583e-01/2*(max(Z(:))-min(Z(:)));
[XX]=lgwt(N(1),min(X(:))-Xp,max(X(:))+Xp);
[YY]=lgwt(N(2),min(Y(:))-Yp,max(Y(:))+Yp);

[ZZ]=lgwt(N(3),min(Z(:))-Zp,max(Z(:))+Zp);
[X,Y,Z]=ndgrid(XX,YY,ZZ);
raux=zeros([3 numel(X)]);
kaux=zeros([3 numel(X) Nj]);
raux(1,:)=X(:)';
raux(2,:)=Y(:)';
raux(3,:)=Z(:)';

clear X Y Z;


for kk=1:Nj
        
Lx=lagrange(rs(1,:,kk),XX');
Ly=lagrange(rs(2,:,kk),YY');
Lz=lagrange(rs(3,:,kk),ZZ');
for k=1:N(3)
for j=1:N(2)
for i=1:N(1)
    L=Lx(i,:).*Ly(j,:).*Lz(k,:);
kaux(1,i+(j-1)*N(1)+(k-1)*N(1)*N(2),kk)=ks(1,:,kk)*L';
kaux(2,i+(j-1)*N(1)+(k-1)*N(1)*N(2),kk)=ks(2,:,kk)*L';
kaux(3,i+(j-1)*N(1)+(k-1)*N(1)*N(2),kk)=ks(3,:,kk)*L';
end
end
end
end

end
function L=lagrange(x,pointx)%,pointy)
%
%LAGRANGE   approx a point-defined function using the Lagrange polynomial interpolation
%
%      LAGRANGE(X,POINTX,POINTY) approx the function definited by the points:
%      P1=(POINTX(1),POINTY(1)), P2=(POINTX(2),POINTY(2)), ..., PN(POINTX(N),POINTY(N))
%      and calculate it in each elements of X
%
%      If POINTX and POINTY have different number of elements the function will return the NaN value
%
%      function wrote by: Calzino
%      7-oct-2001
%
n=size(pointx,2);
L=ones(n,size(x,2));

   for i=1:n
      for j=1:n
         if (i~=j)
            L(i,:)=L(i,:).*(x-pointx(j))/(pointx(i)-pointx(j));
         end
      end
   end
  % y=0;
  % for i=1:n
  %    y=y+pointy(i)*L(i,:);
  % end
end

function [x,w]=lgwt(N,a,b)

% lgwt.m
%
% This script is for computing definite integrals using Legendre-Gauss 
% Quadrature. Computes the Legendre-Gauss nodes and weights  on an interval
% [a,b] with truncation order N
%
% Suppose you have a continuous function f(x) which is defined on [a,b]
% which you can evaluate at any x in [a,b]. Simply evaluate it at all of
% the values contained in the x vector to obtain a vector f. Then compute
% the definite integral using sum(f.*w);
%
% Written by Greg von Winckel - 02/25/2004
N=N-1;
N1=N+1; N2=N+2;

xu=linspace(-1,1,N1)';

% Initial guess
y=cos((2*(0:N)'+1)*pi/(2*N+2))+(0.27/N1)*sin(pi*xu*N/N2);

% Legendre-Gauss Vandermonde Matrix
L=zeros(N1,N2);

% Derivative of LGVM
Lp=zeros(N1,N2);

% Compute the zeros of the N+1 Legendre Polynomial
% using the recursion relation and the Newton-Raphson method

y0=2;

% Iterate until new points are uniformly within epsilon of old points
while max(abs(y-y0))>eps
    
    
    L(:,1)=1;
    Lp(:,1)=0;
    
    L(:,2)=y;
    Lp(:,2)=1;
    
    for k=2:N1
        L(:,k+1)=( (2*k-1)*y.*L(:,k)-(k-1)*L(:,k-1) )/k;
    end
 
    Lp=(N2)*( L(:,N1)-y.*L(:,N2) )./(1-y.^2);   
    
    y0=y;
    y=y0-L(:,N2)./Lp;
    
end

% Linear map from[-1,1] to [a,b]
x=(a*(1-y)+b*(1+y))/2;      

% Compute the weights
w=(b-a)./((1-y.^2).*Lp.^2)*(N2/N1)^2;
end
