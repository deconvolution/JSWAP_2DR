"
Compuites auxiliary variable used to compute sigma, subfunction of JSWAP_CPU_3D_isotropic_solver.
"

@parallel function JSWAP_CPU_2D_isotropic_forward_solver_compute_au_for_sigma(dt,dx,dy,inv_Qa,lambda,mu,
    beta,
    v1_iph_j_1,v1_iph_jp1_2,
    v2_ip1_jph_1,v2_i_jph_2,
    sigmas11_i_j,
    sigmas22_i_j,
    sigmas12_iph_jph,
    ax,ax2,ax3,ax4,ax5,ax6,ax7,
    Ax,Ax2,Ax3,Ax4,Ax5,Ax6,Ax7,
    ax_dt,ax2_dt,ax3_dt,ax4_dt,ax5_dt,ax6_dt,ax7_dt)

    @all(Ax)=@all(ax);
    @all(Ax2)=@all(ax2);
    @all(Ax4)=@all(ax4);
    @all(Ax7)=@all(ax7);

    # sigmas11
    @all(ax)=@all(mu) .*(@all(v1_iph_j_1)/dx)+
    (-@all(mu)) .*(@all(v2_i_jph_2)/dy);

    # sigmas22
    @all(ax2)=(-@all(mu)) .*(@all(v1_iph_j_1)/dx)+
    (@all(mu)) .* (@all(v2_i_jph_2)/dy);

    # sigmas12
    @all(ax4)=@all(mu).*(@all(v2_ip1_jph_1)/dx)+
    @all(mu).*(@all(v1_iph_jp1_2)/dy);

    # p
    @all(ax7)=(@all(lambda)+@all(mu)) .*(@all(v1_iph_j_1)/dx)+
    (@all(lambda)+@all(mu)) .*(@all(v2_i_jph_2)/dy);

    @all(ax_dt)=(@all(ax)-@all(Ax))/dt;
    @all(ax2_dt)=(@all(ax2)-@all(Ax2))/dt;
    @all(ax4_dt)=(@all(ax4)-@all(Ax4))/dt;
    @all(ax7_dt)=(@all(ax7)-@all(Ax7))/dt;

    return nothing
end
