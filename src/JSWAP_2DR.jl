"
module JSWAP

Julia Sound WAve Propagation
"
module JSWAP_2DR
## utilities
include("./utilities//utilities.jl");
## finite-difference solver for isotropic media
include("./waveequation/CPU_2D.jl");
## Eikonal
#include("./eikonalequation/eikonal.jl");
end
