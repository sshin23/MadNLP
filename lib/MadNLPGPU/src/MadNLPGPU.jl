module MadNLPGPU

import CUDA: CUBLAS, CUSOLVER, CuVector, CuMatrix, toolkit_version, R_64F, has_cuda
import MadNLP:
    @kwdef, Logger, @debug, @warn, @error,
    AbstractOptions, AbstractLinearSolver, set_options!, MadNLPLapackCPU,
    SymbolicException,FactorizationException,SolveException,InertiaException,
    introduce, factorize!, solve!, improve!, is_inertia, inertia, tril_to_full!

if has_cuda()
    include("lapackgpu.jl")
    export MadNLPLapackGPU
end

end # module
