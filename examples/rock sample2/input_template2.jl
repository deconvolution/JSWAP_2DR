## load model
#data=JSWAP_2DR.readmat("/media/zhang/second disk/GitHub2/Giovanni/model creation/m1.mat","data");
## dimensions

airN = 60;

# Time increment
dt = 1e-5 / 2;
# dx
dx = 0.2;
# dy
dy = 0.2;
# number of time steps
nt = 4000;
# nx
nx = Int(40 / dx) .+ airN;
# ny
ny = Int(100 / dy) .+ airN;
# 3D true coordinate X, Y and Z
Y, X = JSWAP_2DR.meshgrid((1:ny) * dy, (1:nx) * dx);
## receiver and source configuration.
"
The type of r1,r2,r3,s1,s2 and s3 should not be changed.
"
# receiver grid location x
r1 = zeros(Int64, 1, 2);
r1[:] = ([Int(airN / 2), nx - Int(airN / 2)])  #.+ Int64(airN./2);
# receiver grid location y
r2 = zeros(Int64, 1, 2);
r2[:] = ([Int(airN / 2) + Int(87 / dx), Int(airN / 2) + Int(87 / dx)])  #.+ Int64(airN./2);
# source grid location x
s1 = zeros(Int64, 1, 1);
s1[:] .= Int(airN / 2) + Int(20 / dx);
# source grid location y
s2 = zeros(Int64, 1, 1);
s2[:] .= Int(airN / 2) + Int(20 / dx);

# receiver true location x
r1t = zeros(1, 2);
r1t[:] = [round(Int, r1[1] / dx) round(Int, r1[2] / dx)];
# receiver true location y
r2t = zeros(1, 2);
r2t[:] = [round(Int, r2[1] / dx) round(Int, r2[2] / dx)];
# source true location x
s1t = zeros(1, 1);
s1t[:] .= [round(Int, s1[1] / dx)];
# source true location y
s2t = zeros(1, 1);
s2t[:] .= [round(Int, s2[1] / dx)];
# moment tensor source
src1 = zeros(nt, 1);
src2 = zeros(nt, 1);
srcp = zeros(nt, 1);
freq=2000;
src1[:] = 0 * rickerWave(freq, dt, nt, 2);
src2[:] = 0 * rickerWave(freq, dt, nt, 2);
srcp[:] = 1 * rickerWave(freq, dt, nt, 2);
## material properties
lambda = ones(nx, ny) * 10^10;
lambda = lambda * 1.6;
mu = lambda * 0.85;
rho = ones(nx, ny) * 2400;
inv_Qa = ones(size(lambda)) * (1 / (1000 * 10^5));
#=
layerind=zeros(ny,ny);
layer = Int64(ny/2)-1:Int64(ny/2)+1;
layerind[:,layer] .= 1;
layer = findall(isequal(1),layerind);

angle = pi/3;
layer2 = getindex.(layer, [1 2]) .-ny/2;
newX = ((layer2[:,1]) * cos(angle) - (layer2[:,2]) * sin(angle)) .+ ny/2;
newY = (layer2[:,1] * sin(angle) + layer2[:,2] * cos(angle)) .+ ny/2;
xn = zeros(Int64,size(newX));
yn = zeros(Int64,size(newY));
global index = float(0);
for I = 1:size(newX,1)
  global index = index+1;
  if round(Int,newX[I]) > 0 && round(Int,newX[I]) < size(layerind,1)
    xn[Int(index)] = round(Int,newX[I])
  else
    global index = index-1;
    continue
  end
  if round(Int,newY[I])>0 && round(Int,newY[I]) < size(layerind,1)
    yn[Int(index)] = round(Int,newY[I])
  else
    global index = index-1;
    continue
  end
end

xn = xn[1:Int(index)];
yn = yn[1:Int(index)];

global rotlayer = [xn yn];

layerind=zeros(ny,ny);

for I = 1:size(layer,1)

  layerind[Int(xn[I]),Int(yn[I])] = 1;
  try
    layerind[Int(xn[I]+1),Int(yn[I]+1)] = 1;
  catch
    continue
  end
end

layerind = layerind[Int64((ny-nx)/2):ny-Int64((ny-nx)/2)-1,:];

rotlayer2 = findall(isequal(1),layerind);

lambda[rotlayer2] .= 0.6*10^10;
mu[rotlayer2] = lambda[rotlayer2] .* 0.85;
rho[rotlayer2] .= 1500;
=#
## sample boundary conditions
air = Int64(airN / 2):Int64(airN / 2);

#lambda[:,air] .= 1*10^10;
#lambda[:,(ny+1).-(air)] .= 1*10^10;
#lambda[air,:] .= 1*10^10;
#lambda[(nx+1).-(air),:] .= 1*10^10;

#mu[:,air] .= 0.85*10^10;
#mu[:,(ny+1).-(air)] .= 0.85*10^10;
#mu[air,:] .= 0.85*10^10;
#mu[(nx+1).-(air),:] .= 0.85*10^10;

#rho[:,air] .= 2000;
#rho[:,(ny+1).-(air)] .= 2000;
#rho[air,:] .= 2000;
#rho[(nx+1).-(air),:] .= 2000;


## contacts

air = 1:Int64((airN / 2))-1;

lambda[:, air] .= 0.004 * 10^10;
mu[:, air] .= 0;#0;
rho[:, air] .= 1850;#1;

lambda[:, (ny+1).-(air)] .=0.004 * 10^10;
mu[:, (ny+1).-(air)] .= 0;#0;
rho[:, (ny+1).-(air)] .= 1850;

lambda[air, :] .= 0.004 * 10^10;
mu[air, :] .= 0;#0;
rho[air, :] .= 1850;#1;

lambda[(nx+1).-air, :] .= 0.004 * 10^10;
mu[(nx+1).-air, :] .= 0;#0;
rho[(nx+1).-air, :] .= 1850;#1;
## tune the filter here. Make sure the medium is still an effective medium under
# this frequency, i.e., the fuzzy region should be smaller than the wavelength.
# fil controls the smoothness.
fil=3;
tt=imfilter(lambda, Kernel.gaussian(fil));
heatmap(tt');
##
lambda=imfilter(lambda,Kernel.gaussian(fil));
mu=imfilter(mu,Kernel.gaussian(fil));
rho=imfilter(rho, Kernel.gaussian(fil));
## boundary
# boundary y=? at y plus
KFSyp = ny .- Int64(airN ./ 2);
KFSyp = nothing;
# x-range boundary KFSyp
KFSypxr = [Int64(airN ./ 2), nx .- Int64(airN ./ 2)];
# boundary y=? at y minus
KFSym = Int64(airN ./ 2);
KFSym = nothing;
# x-range boundary KFSym
KFSymxr = [Int64(airN ./ 2), nx .- Int64(airN ./ 2)];
# boundary x=? at x plus
# Be careful of the boundary. For instance, 231 - solid, 232 - air. One needs to
# assign the right grid, which is 232.
KFSxp = 232;
# y-range of boundary KFSxp
KFSxpyr = [Int64(airN ./ 2), ny .- Int64(airN ./ 2)];
# boundary x=? at x minus
KFSxm = 30;
# y-range of boundary KFSxpyr
KFSxmyr = [Int64(airN ./ 2), ny - Int64(airN ./ 2)];
## PML
# PML layers
lp = 10;
# PML power
nPML = 2;
# PML theorecital coefficient
Rc = 0.01;
# set PML active
# xminus,xplus,yminus,yplus
PML_active = [1 1 1 1];
## plot
# plot interval
plot_interval = 300;
# wavefield interval
wavefield_interval = nothing;
