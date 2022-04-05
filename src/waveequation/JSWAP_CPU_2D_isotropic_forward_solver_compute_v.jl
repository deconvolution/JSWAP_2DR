"
Computes v, subfunction of JSWAP_CPU_3D_isotropic_solver.
"
@parallel function JSWAP_CPU_2D_isotropic_forward_solver_compute_v(dt,dx,dy,rho_iph_j,rho_i_jph,beta,
    v1_iph_j,v2_i_jph,
    sigmas11_ip1_j_1,
    sigmas22_i_jp1_2,
    sigmas12_iph_jph_1,sigmas12_iph_jph_2,
    p_ip1_j_1,p_i_jp1_2)

    @all(v1_iph_j)=dt./@all(rho_iph_j) .*((@all(sigmas11_ip1_j_1)-@all(p_ip1_j_1))/dx+
    @all(sigmas12_iph_jph_2)/dy)+
    @all(v1_iph_j)-
    dt*@all(beta) .*@all(v1_iph_j);

    @all(v2_i_jph)=dt./@all(rho_i_jph) .*(@all(sigmas12_iph_jph_1)/dx+
    (@all(sigmas22_i_jp1_2)-@all(p_i_jp1_2))/dy)+
    @all(v2_i_jph)-
    dt*@all(beta) .*@all(v2_i_jph);

    return nothing
end
