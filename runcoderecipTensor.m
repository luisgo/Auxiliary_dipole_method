function [rv,jv]=runcoderecipTensor(te2p,p,conductivity,teid,that,FEMord)
%te2p is 3 by nte
%p is 3 by np
%conductivity 9 by nte
%teid is ntarget by 1
%that is 3 by ntarget
%FEMord is the order of the FEM
%step 1 geometric preprocessing
tic
[te2p2,p2]=femgenmesh_c(te2p,p,FEMord);
toc
%% Step 2 assemble FEM matrix
tic
A=femassembleTensor(te2p2,p2,conductivity,FEMord);
toc
%% Step 3 generate right hand side of equation
tic
nte=numel(te2p2(1,:));
np=numel(p2(1,:));
nsource=numel(that(1,:));
rhs=zeros([np 1]);
if FEMord==1
mex_id_ = 'rhsrecip(i int, i int, i int[xx], i double[xx], i double[xx], i int, io double[xx], i int[x], io double[x])';
[that, rhs] = FEM(mex_id_, nte, np, te2p2, p2, conductivity, nsource, that, teid, rhs, 4, nte, 3, np, 9, nte, 3, nsource, nsource, np);
elseif FEMord==2
mex_id_ = 'rhsrecip2nd(i int, i int, i int[xx], i double[xx], i double[xx], i int, io double[xx], i int[x], io double[x])';
[that, rhs] = FEM(mex_id_, nte, np, te2p2, p2, conductivity, nsource, that, teid, rhs, 10, nte, 3, np, 9, nte, 3, nsource, nsource, np);
elseif FEMord==3
mex_id_ = 'rhsrecip3rd(i int, i int, i int[xx], i double[xx], i double[xx], i int, io double[xx], i int[x], io double[x])';
[that, rhs] = FEM(mex_id_, nte, np, te2p2, p2, conductivity, nsource, that, teid, rhs, 20, nte, 3, np, 9, nte, 3, nsource, nsource, np);
end

toc
%% Step 4 delete one unknown and equation and define preconditioner
A=A(1:end-1,1:end-1);
PRECON=sparse(1:numel(A(:,1)),1:numel(A(:,1)),sqrt(full(diag(A))));
rhs=rhs(1:end-1);
%% Step 5 solve system of equations
tic
x=minres(A,rhs,10^-10,10000,PRECON,PRECON);
x(end+1)=0;
toc
%% Step 6 evaluate field at desired locations
ntens=nte+nsource;
rv=zeros([3,ntens]);
jv=zeros([3,ntens]);
if FEMord==1
mex_id_ = 'conductioncurrTensor(i int[xx], i int, i double[xx], i double[xx], i double[x], io double[xx], io double[xx])';
[rv, jv] = FEM(mex_id_, te2p2, nte, p2, conductivity, x, rv, jv, 4, nte, 3, np, 9, nte, np, 3, ntens, 3, ntens);
elseif FEMord==2
mex_id_ = 'conductioncurr2ndTensor(i int[xx], i int, i double[xx], i double[xx], i double[x], io double[xx], io double[xx])';
[rv, jv] = FEM(mex_id_, te2p2, nte, p2, conductivity, x, rv, jv, 10, nte, 3, np, 9, nte, np, 3, ntens, 3, ntens);
elseif FEMord==3
mex_id_ = 'conductioncurr3rdTensor(i int[xx], i int, i double[xx], i double[xx], i double[x], io double[xx], io double[xx])';
[rv, jv] = FEM(mex_id_, te2p2, nte, p2, conductivity, x, rv, jv, 20, nte, 3, np, 9, nte, np, 3, ntens, 3, ntens);
end
te2p=te2p-1;
np=numel(p(1,:));
mex_id_ = 'impressedcurr(i int[xx], i int, i double[xx], i double[xx], i int[x], i int, io double[xx], io double[xx])';
[rv, jv] = FEM(mex_id_, te2p, nte, p, that, teid, nsource, rv, jv, 4, nte, 3, np, 3, nsource, nsource, 3, ntens, 3, ntens);




