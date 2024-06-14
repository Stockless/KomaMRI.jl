module KomaCUDAExt

using CUDA
import KomaMRICore
import Adapt

KomaMRICore.name(::CUDABackend) = "CUDA"
KomaMRICore.isfunctional(::CUDABackend) = CUDA.functional()
KomaMRICore.set_device!(::CUDABackend, val) = CUDA.device!(val)
KomaMRICore.device_name(::CUDABackend) = CUDA.name(CUDA.device())

Adapt.adapt_storage(::CUDABackend, x::KomaMRICore.NoMotion) = KomaMRICore.NoMotion{Float32}()
Adapt.adapt_storage(::CUDABackend, x::KomaMRICore.SimpleMotion) = KomaMRICore.f32(x)
function Adapt.adapt_storage(::CUDABackend, x::KomaMRICore.ArbitraryMotion)
    fields = []
    for field in fieldnames(KomaMRICore.ArbitraryMotion)
        if field in (:ux, :uy, :uz) 
            push!(fields, Adapt.adapt(CUDABackend(), getfield(x, field)))
        else
            push!(fields, KomaMRICore.f32(getfield(x, field)))
        end
    end
    return KomaMRICore.ArbitraryMotion(fields...)
end
function Adapt.adapt_storage(
    ::CUDABackend, x::Vector{KomaMRICore.LinearInterpolator{T,V}}
) where {T<:Real,V<:AbstractVector{T}}
    return CUDA.cu.(x)
end

function KomaMRICore._print_devices(::CUDABackend)
    devices = [
        Symbol("($(i-1)$(i == 1 ? "*" : " "))") => CUDA.name(d) for
        (i, d) in enumerate(CUDA.devices())
    ]
    @info "$(length(CUDA.devices())) CUDA capable device(s)." devices...
end

function __init__()
    push!(KomaMRICore.LOADED_BACKENDS[], CUDABackend())
end

end