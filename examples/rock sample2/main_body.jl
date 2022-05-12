"""
An example for rock sample simulation.

Output
  One needs paraview for visualization.
  ./test/time_info.pvd to see material properties and wavefield.
  ./test/model/receiver location .csv for receiver location.
  ./test/model/source location .csv for source location.

"""

## import packages
using Revise
using JSWAP_2DR,ImageFiltering,Plots
ti=JSWAP_2DR.TimerOutput();
Threads.nthreads()
## Run solvers
include("./input_template2.jl");
## create folder for saving
p2= @__FILE__;
p3=chop(p2,head=0,tail=3);
if isdir(p3)==0
    mkdir(p3);
end
# path for storage. This must be the master branch of the following pathes.
path=string("./test/");
@JSWAP_2DR.timeit ti "simulation" JSWAP_2DR.CPU_2D.JSWAP_CPU_2D_forward_isotropic_solver(nt=nt,
nx=nx,
ny=ny,
dt=dt,
dx=dx,
dy=dy,
X=X,
Y=Y,
lambda=lambda,
mu=mu,
rho=rho,
inv_Qa=inv_Qa,
s1=s1,
s2=s2,
s1t=s1t,
s2t=s2t,
r1=r1,
r2=r2,
r1t=r1t,
r2t=r2t,
path=path,
wavefield_interval=wavefield_interval,
plot_interval=plot_interval,
src1=src1,
src2=src2,
srcp=srcp,
KFSyp=KFSyp,
KFSypxr=KFSypxr,
KFSym=KFSym,
KFSymxr=KFSymxr,
KFSxp=KFSxp,
KFSxpyr=KFSxpyr,
KFSxm=KFSxm,
KFSxmyr=KFSxmyr,
lp=lp,
Rc=Rc,
nPML=nPML,
PML_active=PML_active);
