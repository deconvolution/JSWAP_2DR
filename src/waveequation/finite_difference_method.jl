"
d/dx, 12-point, subfunction of JSWAP_CPU_2D_isotropic_solver.
"
@parallel function Dx_12(in,out,xs,xs2,ys,ys2)
    @pick(out,xs,xs2,ys,ys2)=@dx_12(in);
    return nothing
end

"
d/dy, 12-point, subfunction of JSWAP_CPU_2D_isotropic_solver.
"
@parallel function Dy_12(in,out,xs,xs2,ys,ys2)
    @pick(out,xs,xs2,ys,ys2)=@dy_12(in);
    return nothing
end
