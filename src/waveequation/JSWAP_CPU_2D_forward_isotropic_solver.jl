"
CPU 2D isotropic forward solver

Input:
nt is the number of time steps.
nx is the number of grids in the x-direciton.
ny is the number of grids in the y-direction.
nz is the number of grids in the z-direction.
dt is the time interval for the simulation.
    dx is the grid spacing in the x-direction.
    dy is the grid spacing in the y-direction.
    dz is the grid spacing in the z-direction.
    X is the x true coordinate.
    Y is the y true coordinate.
    Z is the z true coordinate.
    lambda and mu are the Lame constants.
    rho is the density.
    inv_Qa is the apparent attenuation.
    s1 is the grid location of source in the x-direction.
    s2 is the grid location of source in the y-direction.
    s3 is the grid location of source in the z-direction.
    s1t is the true location of source in the x-direction.
    s2t is the true location of source in the y-direction.
    s3t is the true location of source in the z-direction.
    r1 is the grid location of receiver in the x-direction.
    r2 is the grid location of receiver in the y-direction.
    r3 is the grid location of receiver in the z-direction.
    r1t is the true location of receiver in the x-direction.
    r2t 2 is the true location of receiver in the y-direction.
    r3t is the true location of receiver in the z-direction.
    path is the path where one wants to save the output.
    wavefield_interval is the time interval for saving wavefield, nothing for not saving.
        plot_interval is the time interval for plot the wavefield, nothing for not plotting.
            M11, M22, M33, M23, M13 and M12 are the moment tensors.
            src1, src2, src3 and srcp are the source components for the x-, y-, z- and pressure components.
            lp is the number of PML layers.
            Rc is the theoretical reflectivity for PML.
                nPML is the power of the PML problem, normally 2.
                PML_active is whether or not to activate PML in each direciton.

                Output:
                <path>/model/material_properties.vts is the pareview file to visualize material properties.
                <path>/model/receiver location.csv is the receiver location in a .csv file.
                <path>/model/source location.csv is the source location in a .csv file.
                <path>/pic/ contains .vts files for wavefield visualization in paraview.
                <path>/rec/ contains .mat files for seismograms.
                <path>/wavefield contains .mat files for wavefield.
                <path>/time_info.pvd is a file that can be loaded to paraview for wavefield movie.

                Return:
                v1_iph_j is the v1 component at the last time step.
                v2_i_jph is the v2 component at the last time step.
                v3_i_jph is the v3 component at the last time step.
                R1 is the recording of v1.
                R2 is the recording of v2.
                R3 is the recording of v3.
                P is the recording of pressure.
                "

                function JSWAP_CPU_2D_forward_isotropic_solver(;nt,
                    nx,
                    ny,
                    dt,
                    dx,
                    dy,
                    X,
                    Y,
                    lambda,
                    mu,
                    rho,
                    inv_Qa,
                    s1,
                    s2,
                    s1t,
                    s2t,
                    r1,
                    r2,
                    r1t,
                    r2t,
                    path,
                    wavefield_interval=nothing,
                    plot_interval=nothing,
                    M11=nothing,
                    M22=nothing,
                    M12=nothing,
                    src1=nothing,
                    src2=nothing,
                    srcp=nothing,
                    KFSyp=nothing,
                    KFSypxr=nothing,
                    KFSym=nothing,
                    KFSymxr=nothing,
                    KFSxp=nothing,
                    KFSxpyr=nothing,
                    KFSxm=nothing,
                    KFSxmyr=nothing,
                    lp,
                    Rc,
                    nPML,
                    PML_active)

                    #global data
                    global data
                    # zero stress condition at the boundaries
                    lambda[1:5,:] .=0;
                    lambda[end-4:end,:] .=0;
                    lambda[:,1:5] .=0;
                    lambda[:,end-4:end] .=0;

                    mu[1:5,:] .=0;
                    mu[end-4:end,:] .=0;
                    mu[:,1:5] .=0;
                    mu[:,end-4:end] .=0;

                    nx=floor(Int64,nx);
                    ny=floor(Int64,ny);

                    d0=Dates.now();

                    # source number
                    ns=length(s1);

                    # create main folder
                    if path!=nothing
                        if isdir(path)==0
                            mkdir(path);
                        end
                    end

                    # create folder for picture
                    n_picture=1;
                    n_wavefield=1;
                    path_pic=string(path,"/pic");
                    if path!=nothing
                        if isdir(path_pic)==0
                            mkdir(path_pic);
                        end
                        # initialize pvd
                        pvd=paraview_collection(string(path,"/time_info"));
                    end

                    # create folder for model
                    path_model=string(path,"/model");
                    if path!=nothing
                        if isdir(path_model)==0
                            mkdir(path_model);
                        end
                        vtkfile = vtk_grid(string(path_model,"/material_properties"),X,Y);
                        vtkfile["lambda"]=lambda;
                        vtkfile["mu"]=mu;
                        vtkfile["rho"]=rho;
                        vtk_save(vtkfile);
                        CSV.write(string(path_model,"/receiver location.csv"),DataFrame([r1t' r2t'],:auto));
                        CSV.write(string(path_model,"/source location.csv"),DataFrame([s1t' s2t'],:auto));
                    end

                    # create folder for wavefield
                    path_wavefield=string(path,"/wavefield");
                    if path!=nothing
                        if isdir(path_wavefield)==0
                            mkdir(path_wavefield)
                        end
                    end

                    # create folder for rec
                    path_rec=string(path,"/rec");
                    if path!=nothing
                        if isdir(path_rec)==0
                            mkdir(path_rec)
                        end
                    end

                    beta=isotropic_PML_configuration(nx,ny,dx,dy,
                    lambda,mu,rho,nPML,Rc,lp,PML_active);

                    # receiver configuration
                    R1=@zeros(nt,length(r1));
                    R2=copy(R1);
                    P=@zeros(nt,length(r1));

                    # decompose moment tensor
                    if M11!=nothing
                        Mp=-1/2*(M11+M22);
                        Ms11=M11+Mp;
                        Ms22=M22+Mp;
                        Ms12=M12;

                        Mp_t=@zeros(size(M11));
                        Ms11_t=copy(Mp_t);
                        Ms22_t=copy(Mp_t);
                        Ms12_t=copy(Mp_t);

                        Mp_t[1:end-1,:]=diff(Mp,dims=1)/dt;
                        Ms11_t[1:end-1,:]=diff(Ms11,dims=1)/dt;
                        Ms22_t[1:end-1,:]=diff(Ms22,dims=1)/dt;
                        Ms12_t[1:end-1,:]=diff(Ms12,dims=1)/dt;
                    end
                    dx=dx;
                    dy=dy;
                    # coefficient
                    rho_iph_j=copy(rho);
                    rho_i_jph=copy(rho);
                    lambda_i_j=copy(lambda);
                    mu_i_j=copy(mu);
                    mu_iph_jph=copy(mu);

                    #rho_iph_j[1:end-1,:]=.5*(rho[1:end-1,:]+rho[2:end,:]);
                    #rho_i_jph[:,1:end-1]=.5*(rho[:,1:end-1]+rho[:,2:end]);
                    #mu_iph_jph[2:end,2:end]=1*(mu[2:end,2:end]);

                    # wave vector
                    v1_iph_j=@zeros(nx,ny);
                    v2_i_jph=copy(v1_iph_j);

                    sigmas11_i_j=copy(v1_iph_j);
                    sigmas22_i_j=copy(v1_iph_j);
                    sigmas12_iph_jph=copy(v1_iph_j);
                    p_i_j=copy(v1_iph_j);

                    # derivatives
                    v1_iph_j_1=copy(v1_iph_j);
                    v1_iph_jp1_2=copy(v1_iph_j);
                    v2_ip1_jph_1=copy(v1_iph_j);
                    v2_i_jph_2=copy(v1_iph_j);

                    sigmas11_ip1_j_1=copy(v1_iph_j);
                    sigmas22_i_jp1_2=copy(v1_iph_j);
                    sigmas12_iph_jph_1=copy(v1_iph_j);
                    sigmas12_iph_jph_2=copy(v1_iph_j);

                    p_ip1_j_1=copy(v1_iph_j);
                    p_i_jp1_2=copy(v1_iph_j);

                    ax=copy(v1_iph_j);
                    ax2=copy(v1_iph_j);
                    ax3=copy(v1_iph_j);
                    ax4=copy(v1_iph_j);
                    ax5=copy(v1_iph_j);
                    ax6=copy(v1_iph_j);
                    ax7=copy(v1_iph_j);
                    Ax=copy(v1_iph_j);
                    Ax2=copy(v1_iph_j);
                    Ax3=copy(v1_iph_j);
                    Ax4=copy(v1_iph_j);
                    Ax5=copy(v1_iph_j);
                    Ax6=copy(v1_iph_j);
                    Ax7=copy(v1_iph_j);
                    ax_dt=copy(v1_iph_j);
                    ax2_dt=copy(v1_iph_j);
                    ax3_dt=copy(v1_iph_j);
                    ax4_dt=copy(v1_iph_j);
                    ax5_dt=copy(v1_iph_j);
                    ax6_dt=copy(v1_iph_j);
                    ax7_dt=copy(v1_iph_j);

                    l=1;
                    pro_bar=Progress(nt,1,"forward_simulation...",50);

                    for l=1:nt-1
                        # plus: 6:5
                        # minus: 5:6
                        #@parallel Dx_inn(v1_iph_j,dtt1);
                        #@parallel (2:ny-1,2:nz-1) u_1_plus(dtt1,v1_iph_j_1);
                        @parallel Dx_12(v1_iph_j,v1_iph_j_1,6,5,0,0);

                        #@parallel Dy_inn(v1_iph_j,dtt2);
                        #@parallel (2:nx-1,2:nz-1) u_2_minus(dtt2,v1_iph_jp1_2);
                        @parallel Dy_12(v1_iph_j,v1_iph_jp1_2,0,0,5,6);
                        if KFSyp!=nothing
                            v1_iph_jp1_2[KFSypxr[1]:KFSypxr[2],KFSyp+1]=(v1_iph_j[KFSypxr[1]:KFSypxr[2],KFSyp+2]-v1_iph_j[KFSypxr[1]:KFSypxr[2],KFSyp+1])/dy;
                            v1_iph_jp1_2[KFSypxr[1]:KFSypxr[2],KFSyp-1]=(v1_iph_j[KFSypxr[1]:KFSypxr[2],KFSyp]-v1_iph_j[KFSypxr[1]:KFSypxr[2],KFSyp-1])/dy;
                        end
                        if KFSym!=nothing
                            v1_iph_jp1_2[KFSymxr[1]:KFSymxr[2],KFSym+1]=(v1_iph_j[KFSymxr[1]:KFSymxr[2],KFSym+2]-v1_iph_j[KFSymxr[1]:KFSymxr[2],KFSym+1])/dy;
                            v1_iph_jp1_2[KFSymxr[1]:KFSymxr[2],KFSym-1]=(v1_iph_j[KFSymxr[1]:KFSymxr[2],KFSym]-v1_iph_j[KFSymxr[1]:KFSymxr[2],KFSym-1])/dy;
                        end
                        #@parallel Dx_inn(v2_i_jph,dtt1);
                        #@parallel (2:ny-1,2:nz-1) u_1_minus(dtt1,v2_ip1_jph_1);
                        @parallel Dx_12(v2_i_jph,v2_ip1_jph_1,5,6,0,0);
                        if KFSxp!=nothing
                            v2_ip1_jph_1[KFSxp+1,KFSxpyr[1]:KFSxpyr[2]]=(v2_i_jph[KFSxp+2,KFSxpyr[1]:KFSxpyr[2]]-v2_i_jph[KFSxp+1,KFSxpyr[1]:KFSxpyr[2]])/dx;
                            v2_ip1_jph_1[KFSxp-1,KFSxpyr[1]:KFSxpyr[2]]=(v2_i_jph[KFSxp,KFSxpyr[1]:KFSxpyr[2]]-v2_i_jph[KFSxp-1,KFSxpyr[1]:KFSxpyr[2]])/dx;
                        end
                        if KFSxm!=nothing
                            v2_ip1_jph_1[KFSxm+1,KFSxmyr[1]:KFSxmyr[2]]=(v2_i_jph[KFSxm+2,KFSxmyr[1]:KFSxmyr[2]]-v2_i_jph[KFSxm+1,KFSxmyr[1]:KFSxmyr[2]])/dx;
                            v2_ip1_jph_1[KFSxm-1,KFSxmyr[1]:KFSxmyr[2]]=(v2_i_jph[KFSxm,KFSxmyr[1]:KFSxmyr[2]]-v2_i_jph[KFSxm-1,KFSxmyr[1]:KFSxmyr[2]])/dx;
                        end
                        # @parallel Dy_inn(v2_i_jph,dtt2);
                        # @parallel (2:nx-1,2:nz-1) u_2_plus(dtt2,v2_i_jph_2);
                        @parallel Dy_12(v2_i_jph,v2_i_jph_2,0,0,6,5);

                        @timeit ti "compute_sigma" @parallel JSWAP_CPU_2D_isotropic_forward_solver_compute_au_for_sigma(dt,dx,dy,inv_Qa,
                        lambda_i_j,mu_i_j,
                        mu_iph_jph,
                        beta,
                        v1_iph_j_1,v1_iph_jp1_2,
                        v2_ip1_jph_1,v2_i_jph_2,
                        sigmas11_i_j,
                        sigmas22_i_j,
                        sigmas12_iph_jph,
                        ax,ax2,ax3,ax4,ax5,ax6,ax7,
                        Ax,Ax2,Ax3,Ax4,Ax5,Ax6,Ax7,
                        ax_dt,ax2_dt,ax3_dt,ax4_dt,ax5_dt,ax6_dt,ax7_dt);

                        if KFSyp!=nothing
                            sigmas12_iph_jph[KFSypxr[1]:KFSypxr[2],KFSyp] .=0;
                        end
                        if KFSym!=nothing
                            sigmas12_iph_jph[KFSymxr[1]:KFSymxr[2],KFSym] .=0;
                        end
                        if KFSxp!=nothing
                            sigmas12_iph_jph[KFSxp:KFSxp,KFSxpyr[1]:KFSxpyr[2]] .=0;
                        end
                        if KFSxm!=nothing
                            sigmas12_iph_jph[KFSxm:KFSxm,KFSxmyr[1]:KFSxmyr[2]] .=0;
                        end

                        @timeit ti "compute_sigma" @parallel JSWAP_CPU_2D_isotropic_forward_solver_compute_sigma(dt,dx,dy,inv_Qa,lambda,mu,
                        beta,
                        sigmas11_i_j,
                        sigmas22_i_j,
                        sigmas12_iph_jph,
                        p_i_j,
                        ax,ax2,ax3,ax4,ax5,ax6,ax7,
                        Ax,Ax2,Ax3,Ax4,Ax5,Ax6,Ax7,
                        ax_dt,ax2_dt,ax3_dt,ax4_dt,ax5_dt,ax6_dt,ax7_dt);

                        # moment tensor source
                        if M11!=nothing
                            if ns==1 && l<=size(Ms11_t,1)
                                sigmas11_i_j[CartesianIndex.(s1,s2)]=sigmas11_i_j[CartesianIndex.(s1,s2)]-@ones(1,1)*dt/dx/dy*Ms11_t[l];
                                sigmas22_i_j[CartesianIndex.(s1,s2)]=sigmas22_i_j[CartesianIndex.(s1,s2)]-@ones(1,1)*dt/dx/dy*Ms22_t[l];
                                sigmas12_iph_jph[CartesianIndex.(s1,s2)]=sigmas12_iph_jph[CartesianIndex.(s1,s2)]-@ones(1,1)*dt/dx/dy*Ms12_t[l];
                                p_i_j[CartesianIndex.(s1,s2)]=p_i_j[CartesianIndex.(s1,s2)]-@ones(1,1)*dt/dx/dy*Mp_t[l];
                            end

                            if ns>=2 && l<=size(Ms11_t,1)
                                sigmas11_i_j[CartesianIndex.(s1,s2)]=sigmas11_i_j[CartesianIndex.(s1,s2)]-dt/dx/dy*Ms11_t[l,:]';
                                sigmas22_i_j[CartesianIndex.(s1,s2)]=sigmas22_i_j[CartesianIndex.(s1,s2)]-dt/dx/dy*Ms22_t[l,:]';
                                sigmas12_iph_jph[CartesianIndex.(s1,s2)]=sigmas12_iph_jph[CartesianIndex.(s1,s2)]-dt/dx/dy*Ms12_t[l,:]';
                                p_i_j[CartesianIndex.(s1,s2)]=p_i_j[CartesianIndex.(s1,s2)]-dt/dx/dy*Mp_t[l,:]';
                            end
                        end

                        @parallel Dx_12(sigmas11_i_j,sigmas11_ip1_j_1,5,6,0,0);
                        @parallel Dy_12(sigmas22_i_j,sigmas22_i_jp1_2,0,0,5,6);
                        @parallel Dx_12(sigmas12_iph_jph,sigmas12_iph_jph_1,6,5,0,0);
                        @parallel Dy_12(sigmas12_iph_jph,sigmas12_iph_jph_2,0,0,6,5);
                        #=
                        if KFSyp!=nothing
                            sigmas12_iph_jph_2[KFSypxr[1]:KFSypxr[2],KFSyp+1]=sigmas12_iph_jph[KFSypxr[1]:KFSypxr[2],KFSyp+1]/dy;
                            sigmas12_iph_jph_2[KFSypxr[1]:KFSypxr[2],KFSyp]=-sigmas12_iph_jph[KFSypxr[1]:KFSypxr[2],KFSyp-1]/dy;
                        end
                        if KFSym!=nothing
                            sigmas12_iph_jph_2[KFSymxr[1]:KFSymxr[2],KFSym+1]=sigmas12_iph_jph[KFSymxr[1]:KFSymxr[2],KFSym+1]/dy;
                            sigmas12_iph_jph_2[KFSymxr[1]:KFSymxr[2],KFSym]=-sigmas12_iph_jph[KFSymxr[1]:KFSymxr[2],KFSym-1]/dy;
                        end

                        if KFSxp!=nothing
                            sigmas12_iph_jph_1[KFSxp+1,KFSxpyr[1]:KFSxpyr[2]]=sigmas12_iph_jph[KFSxp+1,KFSxpyr[1]:KFSxpyr[2]]/dx;
                            sigmas12_iph_jph_1[KFSxp,KFSxpyr[1]:KFSxpyr[2]]=-sigmas12_iph_jph[KFSxp-1,KFSxpyr[1]:KFSxpyr[2]]/dx;
                        end
                        if KFSxm!=nothing
                            sigmas12_iph_jph_1[KFSxm+1,KFSxmyr[1]:KFSxmyr[2]]=sigmas12_iph_jph[KFSxm+1,KFSxmyr[1]:KFSxmyr[2]]/dx;
                            sigmas12_iph_jph_1[KFSxm,KFSxmyr[1]:KFSxmyr[2]]=-sigmas12_iph_jph[KFSxm-1,KFSxmyr[1]:KFSxmyr[2]]/dx;
                        end
                        =#
                        @parallel Dx_12(p_i_j,p_ip1_j_1,5,6,0,0);
                        @parallel Dy_12(p_i_j,p_i_jp1_2,0,0,5,6);


                        @timeit ti "compute_v" @parallel JSWAP_CPU_2D_isotropic_forward_solver_compute_v(dt,dx,dy,rho_iph_j,rho_i_jph,beta,
                        v1_iph_j,v2_i_jph,
                        sigmas11_ip1_j_1,
                        sigmas22_i_jp1_2,
                        sigmas12_iph_jph_1,sigmas12_iph_jph_2,
                        p_ip1_j_1,p_i_jp1_2);

                        if src1!=nothing
                            if ns==1 && l<=size(src1,1)
                                v1_iph_j[CartesianIndex.(s1,s2)]=v1_iph_j[CartesianIndex.(s1,s2)]+1 ./rho[CartesianIndex.(s1,s2)] .*src1[l];
                                v2_i_jph[CartesianIndex.(s1,s2)]=v2_i_jph[CartesianIndex.(s1,s2)]+1 ./rho[CartesianIndex.(s1,s2)] .*src2[l];
                                p_i_j[CartesianIndex.(s1,s2)]=p_i_j[CartesianIndex.(s1,s2)]+@ones(1,1) .*srcp[l];
                            end
                            if ns>=2 && l<=size(src1,1)
                                v1_iph_j[CartesianIndex.(s1,s2)]=v1_iph_j[CartesianIndex.(s1,s2)]+1 ./rho[CartesianIndex.(s1,s2)] .*src1[l,:]';
                                v2_i_jph[CartesianIndex.(s1,s2)]=v2_i_jph[CartesianIndex.(s1,s2)]+1 ./rho[CartesianIndex.(s1,s2)] .*src2[l,:]';
                                p_i_j[CartesianIndex.(s1,s2)]=p_i_j[CartesianIndex.(s1,s2)]+@ones(1,ns) .*srcp[l,:]';
                            end
                        end

                        # assign recordings
                        @timeit ti "receiver" R1[l+1,:]=reshape(v1_iph_j[CartesianIndex.(r1,r2)],length(r1),);
                        @timeit ti "receiver" R2[l+1,:]=reshape(v2_i_jph[CartesianIndex.(r1,r2)],length(r1),);
                        @timeit ti "receiver" P[l+1,:]=reshape(p_i_j[CartesianIndex.(r1,r2)],length(r1),);

                        # save wavefield
                        if wavefield_interval!=nothing && path!=nothing
                            if mod(l,wavefield_interval)==0
                                data=v1_iph_j;
                                write2mat(string(path_wavefield,"/v1_",n_wavefield,".mat"),data);
                                data=v2_i_jph;
                                write2mat(string(path_wavefield,"/v2_",n_wavefield,".mat"),data);
                                data=sigmas11_i_j;
                                write2mat(string(path_wavefield,"/sigmas11_",n_wavefield,".mat"),data);
                                data=sigmas22_i_j;
                                write2mat(string(path_wavefield,"/sigmas22_",n_wavefield,".mat"),data);
                                data=sigmas12_iph_jph;
                                write2mat(string(path_wavefield,"/sigmas12_",n_wavefield,".mat"),data);
                                data=p_i_j;
                                write2mat(string(path_wavefield,"/p_",n_wavefield,".mat"),data);
                                n_wavefield=n_wavefield+1;
                            end
                        end

                        # plot
                        if plot_interval!=nothing && path!=nothing
                            if mod(l,plot_interval)==0 || l==nt-1
                                vtkfile=vtk_grid(string(path_pic,"/wavefield_pic_",n_picture),X,Y);
                                vtkfile["v1"]=v1_iph_j;
                                vtkfile["v2"]=v2_i_jph;
                                vtkfile["p"]=p_i_j;
                                vtkfile["lambda"]=lambda;
                                vtkfile["mu"]=mu;
                                vtkfile["rho"]=rho;
                                pvd[dt*(l+1)]=vtkfile;
                                n_picture=n_picture+1;
                            end
                        end
                        next!(pro_bar);
                    end

                    if path!=nothing
                        data=zeros(nt,1);
                        data[:]=dt:dt:dt*nt;
                        write2mat(string(path_rec,"/t.mat"),data);
                        data=R1;
                        write2mat(string(path_rec,"/rec_1.mat"),data);
                        data=R2;
                        write2mat(string(path_rec,"/rec_2.mat"),data);
                        data=P;
                        write2mat(string(path_rec,"/rec_p.mat"),data);
                    end

                    if plot_interval!=nothing && path!=nothing
                        vtk_save(pvd);
                    end
                    return v1_iph_j,v2_i_jph,R1,R2,P
                end
