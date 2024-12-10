# # Experimental: Simulating with realistic coils

using KomaMRI, MAT # hide
sys = Scanner() # hide
obj = brain_phantom2D()
coil_sens1 = exp.(-π * (((obj.x) .+ 0.1) .^ 2 / 0.01) .+ ((obj.y) .^ 2 / 0.1))
coil_sens2 = exp.(-π * (((obj.x) .- 0.1) .^ 2 / 0.01) .+ ((obj.y) .^ 2 / 0.1))
coil_sens = hcat(coil_sens1, coil_sens2)
obj.coil_sens = coil_sens
seq_file = joinpath(
    dirname(pathof(KomaMRI)),
    "../examples/5.koma_paper/comparison_accuracy/sequences/EPI/epi_100x100_TE100_FOV230.seq",
)
seq = read_seq(seq_file)
# And simulate:

raw = simulate(obj, seq, sys) # hide
##
acq = AcquisitionData(raw) # hide
acq.traj[1].circular = false # hide
Nx, Ny = raw.params["reconSize"][1:2] # hide
reconParams = Dict{Symbol,Any}(:reco => "direct", :reconSize => (Nx, Ny)) # hide
image = reconstruction(acq, reconParams) # hide
slice_abs1 = abs.(image[:, :, 1, 1, 1, 1]) # hide
slice_abs2 = abs.(image[:, :, 1, 1, 2, 1]) # hide
p3 = plot_image(slice_abs1; height=400)
p4 = plot_image(slice_abs2; height=400) # hide
[p3 p4]