## load model
data=JSWAP_2DR.readmat("/media/zhang/second disk/GitHub2/Giovanni/model creation/m1.mat","data");
## dimensions
# Time increment
dt=10^-3;
# dx
dx=10;
# dy
dy=10;
# number of time steps
nt=1000;
# nx
nx=100;
# ny
ny=100;
# 3D true coordinate X, Y and Z
Y,X=JSWAP_2DR.meshgrid((1:ny)*dy,(1:nx)*dx);
## receiver and source configuration.
"
The type of r1,r2,r3,s1,s2 and s3 should not be changed.
"
# receiver grid location x
r1=zeros(Int64,1,2);
r1[:] =[40,60];
# receiver grid location y
r2=zeros(Int64,1,2);
r2[:] =[40,60];
# source grid location x
s1=zeros(Int64,1,1);
s1[:] .=50;
# source grid location y
s2=zeros(Int64,1,1);
s2[:] .=50;

# receiver true location x
r1t=zeros(1,2);
r1t[:]=[400,600];
# receiver true location y
r2t=zeros(1,2);
r2t[:]=[400,600];
# source true location x
s1t=zeros(1,1);
s1t[:] .=500;
# source true location y
s2t=zeros(1,1);
s2t[:] .=500;
# moment tensor source
M11=zeros(nt,1);
M22=zeros(nt,1);
M12=zeros(nt,1);
freq=15;
M11[:]=0*rickerWave(freq,dt,nt,2);
M22[:]=1*rickerWave(freq,dt,nt,2);
M12[:]=0*rickerWave(freq,dt,nt,2);
## material properties
lambda=ones(nx,ny)*10^9;
air=1:29;
lambda[:,air] .=340^2;
mu[:,air] .=0;
rho[:,air] .=1;

lambda[:,(ny+1).-(air)] .=340^2;
mu[:,(ny+1).-(air)]  .=0;
rho[:,(ny+1).-(air)]  .=1;

lambda[air,:] .=340^2;
mu[air,:] .=0;
rho[air,:] .=1;

lambda[(nx+1).-(air),:] .=340^2;
mu[(nx+1).-(air),:]  .=0;
rho[(nx+1).-(air),:]  .=1;

mu=ones(nx,ny)*10^9;
rho=ones(nx,ny)*1000;
inv_Qa=zeros(size(lambda));
## boundary
# boundary y=? at y plus
KFSyp=70;
# x-range boundary KFSyp
KFSypxr=[30,70];
# boundary y=? at y minus
KFSym=30;
# x-range boundary KFSym
KFSymxr=[30,70];
# boundary x=? at x plus
KFSxp=70;
# y-range of boundary KFSxp
KFSxpyr=[30,70];
# boundary x=? at x minus
KFSxm=30;
# y-range of boundary KFSxpyr
KFSxmyr=[30,70];
## PML
# PML layers
lp=20;
# PML power
nPML=2;
# PML theorecital coefficient
Rc=.1;
# set PML active
# xminus,xplus,yminus,yplus
PML_active=[1 1 1 1];
## plot
# plot interval
plot_interval=50;
# wavefield interval
wavefield_interval=nothing;
