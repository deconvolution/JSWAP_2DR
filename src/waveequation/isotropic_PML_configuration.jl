"
Configure PML
"
function isotropic_PML_configuration(nx,ny,dx,dy,lambda,mu,rho,nPML,Rc,lp,PML_active)
    # PML
    vmax=sqrt.((lambda+2*mu) ./rho);
    beta0=(ones(nx,ny) .*vmax .*(nPML+1) .*log(1/Rc)/2/lp/((dx+dy)/3));
    beta1=(zeros(nx,ny));
    beta2=copy(beta1);
    tt=(1:lp)/lp;
    # PML coefficient
    # 6:lp+1
    # nx-lp-5
    beta1=zeros(nx,ny);
    tt=copy(beta1);
    tt[5+2:5+lp+1,:]=repeat(reshape((abs.((1:lp) .-lp .-1) ./lp) .^nPML,lp,1,1),1,ny);
    tt[-5+nx-lp:-5+nx-1,:]=repeat(reshape(((abs.(nx .-lp .-(nx-lp+1:nx))) ./lp) .^nPML,lp,1,1),1,ny);
    beta1=vmax*(nPML+1)*log(1/Rc)/2/lp/dx.*tt;

    beta2=zeros(nx,ny);
    tt=copy(beta2);
    tt[:,5+2:5+lp+1]=repeat(reshape((abs.((1:lp) .-lp .-1) ./lp) .^nPML,1,lp,1),nx,1);
    tt[:,-5+ny-lp:-5+ny-1]=repeat(reshape(((abs.(ny .-lp .-(ny-lp+1:ny))) ./lp) .^nPML,1,lp,1),nx,1);
    beta2=vmax*(nPML+1)*log(1/Rc)/2/lp/dy.*tt;

    for i=1:6
        beta1[i,:] .=beta1[7,:];
    end

    for i=nx-5:nx
        beta1[i,:]=beta1[end-6,:];
    end

    for j=1:6
        beta2[:,j]=beta2[:,7];
    end
    for j=ny-5:ny
        beta2[:,j]=beta2[:,end-6];
    end
    if PML_active[1]==0
        beta1[5+2:5+lp+1,5+lp+2:-5+ny-lp-1] .=0;
    end

    if PML_active[2]==0
        beta1[-5+nx-lp:-5+nx-1,5+lp+2:-5+ny-lp-1] .=0;
    end

    if PML_active[3]==0
        beta2[5+lp+2:-5+nx-lp-1,5+2:5+lp+1] .=0;
    end

    if PML_active[4]==0
        beta2[5+lp+2:-5+nx-lp-1,-5+ny-lp:-5+ny-1] .=0;
    end

    # 3D PML coefficient
    IND=unique(findall(x->x!=0,beta1.*beta2));
    IND2=unique(findall(x->x==x,beta1.*beta2));
    # IND3=setdiff(IND2,IND);
    beta=beta1+beta2;
    beta[IND]=beta[IND]/2;
    return beta
end
