using Mimi
using Base.Test
using ExcelReaders

include("../src/parameters.jl")
include("../src/components/damages_component.jl")

@testset "damages" begin

Precision = 1.0e-11
T = length(dice2010.model_years)
f = openxl(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, dice2010.model_years)

addcomponent(m, damages, :damages)

# Set the parameters that would normally be internal connection from their Excel values
set_parameter!(m, :damages, :TATM, read_params(f, "B121:BI121", T))
set_parameter!(m, :damages, :YGROSS, read_params(f, "B92:BI92", T))
set_parameter!(m, :damages, :TotSLR, read_params(f, "B182:BI182", T))

# Load the rest of the external parameters
p = dice2010_excel_parameters(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))
set_parameter!(m, :damages, :a1, p[:a1])
set_parameter!(m, :damages, :a2, p[:a2])
set_parameter!(m, :damages, :a3, p[:a3])
set_parameter!(m, :damages, :b1, p[:slrcoeff])
set_parameter!(m, :damages, :b2, p[:slrcoeffsq])
set_parameter!(m, :damages, :b3, p[:slrexp])

# Run the one-component model
run(m)

# Extract the generated variables
DAMFRAC = m[:damages, :DAMFRAC]

# Extract the true values
True_DAMFRAC    = read_params(f, "B93:BI93", T)

# Test that the values are the same
@test maximum(abs, DAMFRAC .- True_DAMFRAC) ≈ 0. atol = Precision

end