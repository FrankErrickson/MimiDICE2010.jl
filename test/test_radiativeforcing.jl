using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/radiativeforcing_component.jl")

@testset "radiativeforcing" begin

Precision = 1.0e-11
T = 60
f = openxl(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, collect(2005:10:2595))

addcomponent(m, radiativeforcing, :radiativeforcing)

# Set the parameters that would normally be internal connection from their Excel values
set_parameter!(m, :radiativeforcing, :MAT, getparams(f, "B112:BI112", :all, "Base", T))
set_parameter!(m, :radiativeforcing, :MAT61, getparams(f, "BJ112:BJ112", :single, "Base", 1))

# Load the rest of the external parameters
p = getdice2010excelparameters(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))
set_parameter!(m, :radiativeforcing, :forcoth, p[:forcoth])
set_parameter!(m, :radiativeforcing, :fco22x, p[:fco22x])

# Run the one-component model
run(m)

# Extract the generated variables
FORC = m[:radiativeforcing, :FORC]

# Extract the true values
True_FORC    = getparams(f, "B122:BI122", :all, "Base", T)

# Test that the values are the same
@test maximum(abs, FORC .- True_FORC) ≈ 0. atol = Precision

end