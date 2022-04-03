"
Comp_i_jutes sigma, subfunction of JSWAp_i_j_Cp_i_jU_3D_isotrop_i_jic_solver.
"

@parallel function JSWAP_CPU_2D_isotropic_forward_solver_compute_sigma(dt,dx,dy,inv_Qa,lambda,mu,
    beta,
    sigmas11_i_j,
    sigmas22_i_j,
    sigmas12_iph_jph,
    p_i_j,
    ax,ax2,ax3,ax4,ax5,ax6,ax7,
    Ax,Ax2,Ax3,Ax4,Ax5,Ax6,Ax7,
    ax_dt,ax2_dt,ax3_dt,ax4_dt,ax5_dt,ax6_dt,ax7_dt)

    @all(sigmas11_i_j)=1*dt*(
    @all(ax)+@all(inv_Qa) .*@all(ax_dt))+
    @all(sigmas11_i_j)-
    dt*@all(beta).*@all(sigmas11_i_j);

    @all(sigmas22_i_j)=1*dt*(
    @all(ax2)+@all(inv_Qa) .*@all(ax2_dt))+
    @all(sigmas22_i_j)-
    dt*@all(beta).*@all(sigmas22_i_j);

    @all(sigmas12_iph_jph)=dt*(
    @all(ax4)+@all(inv_Qa) .*@all(ax4_dt))+
    @all(sigmas12_iph_jph)-
    dt*@all(beta).*@all(sigmas12_iph_jph);

    @all(p_i_j)=-1*dt*(
    @all(ax7)+@all(inv_Qa) .*@all(ax7_dt))+
    @all(p_i_j)-
    dt*@all(beta).*@all(p_i_j);

    return nothing
end
