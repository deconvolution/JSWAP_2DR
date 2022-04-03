## timing
ti=TimerOutput();
## finite-difference method package
include("./finite_difference_method.jl");

## isotropic
## function configure_PML
include("./isotropic_PML_configuration.jl");
## function JSWAP_CPU_2D_isotropic_forward_solver and its dependencies
# function JSWAP_CPU_2D_isotropic_forward_solver_compute_au_for_sigma
include("./JSWAP_CPU_2D_isotropic_forward_solver_compute_au_for_sigma.jl");
# function JSWAP_CPU_2D_isotropic_forward_solver_compute_sigma
include("./JSWAP_CPU_2D_isotropic_forward_solver_compute_sigma.jl");
# function JSWAP_CPU_2D_isotropic_forward_solver_compute_v
include("./JSWAP_CPU_2D_isotropic_forward_solver_compute_v.jl");
#
include("./JSWAP_CPU_2D_forward_isotropic_solver.jl");
