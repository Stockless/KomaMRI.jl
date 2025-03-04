# Hardware limits
@with_kw mutable struct HardwareLimits{T}
    B0::T = 1.5
    B1::T = 10e-6
    Gmax::T = 60e-3
    Smax::T = 500
    ADC_Δt::T = 2e-6
    seq_Δt::T = 1e-5
    GR_Δt::T = 1e-5
    RF_Δt::T = 1e-6
    RF_ring_down_T::T = 20e-6
    RF_dead_time_T::T = 100e-6
    ADC_dead_time_T::T = 10e-6
end

# Gradients
abstract type Gradients{T} end
struct LinearXYZGradients{T} <: Gradients{T} end

# RF coils
abstract type RFCoils{T} end
struct UniformRFCoils{T} <: RFCoils{T} end

struct ArbitraryRFCoils{T} <: RFCoils{T}
    x::AbstractVector{T} 
    y::AbstractVector{T} 
    z::AbstractVector{T} 
    coil_sens::AbstractMatrix{Complex{T}}  
    B1::AbstractMatrix{Complex{T}} 
end

export ArbitraryCoils

"""
    sys = Scanner(B0, B1, Gmax, Smax, ADC_Δt, seq_Δt, GR_Δt, RF_Δt,
        RF_ring_down_T, RF_dead_time_T, ADC_dead_time_T)

The Scanner struct. It contains hardware limitations of the MRI resonator. It is an input
for the simulation.

# Arguments
- `B0`: (`::Real`, `=1.5`, `[T]`) main magnetic field strength
- `B1`: (`::Real`, `=10e-6`, `[T]`) maximum RF amplitude
- `Gmax`: (`::Real`, `=60e-3`, `[T/m]`) maximum gradient amplitude
- `Smax`: (`::Real`, `=500`, `[mT/m/ms]`) gradient's maximum slew-rate
- `ADC_Δt`: (`::Real`, `=2e-6`, `[s]`) ADC raster time
- `seq_Δt`: (`::Real`, `=1e-5`, `[s]`) sequence-block raster time
- `GR_Δt`: (`::Real`, `=1e-5`, `[s]`) gradient raster time
- `RF_Δt`: (`::Real`, `=1e-6`, `[s]`) RF raster time
- `RF_ring_down_T`: (`::Real`, `=20e-6`, `[s]`) RF ring down time
- `RF_dead_time_T`: (`::Real`, `=100e-6`, `[s]`) RF dead time
- `ADC_dead_time_T`: (`::Real`, `=10e-6`, `[s]`) ADC dead time

# Returns
- `sys`: (`::Scanner`) Scanner struct

# Examples
```julia-repl
julia> sys = Scanner()

julia> sys.B0
```
"""
@with_kw struct Scanner{T}
    limits::HardwareLimits{T} = HardwareLimits{T}()
    gradients::Gradients{T} = LinearXYZGradients{T}()
    rf_coils::RFCoils{T} = UniformRFCoils{T}()
end

function ArbitraryCoils(x::AbstractVector{T}, y::AbstractVector{T}, z::AbstractVector{T},
    coil_sens::AbstractMatrix{Complex{T}}, B1::AbstractMatrix{Complex{T}}) where T
    rf_coils = ArbitraryRFCoils{T}(x, y, z, coil_sens, B1)
    return Scanner{T}(rf_coils=rf_coils)
end