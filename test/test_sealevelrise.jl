using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/sealevelrise_component.jl")

@testset "sealevelrise" begin

Precision = 1.0e-11
T = 60
f = openxl(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, collect(2005:10:2595))

addcomponent(m, sealevelrise, :sealevelrise)

# Set the parameters that would normally be internal connection from their Excel values
set_parameter!(m, :sealevelrise, :TATM, getparams(f, "B121:BI121", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))
set_parameter!(m, :sealevelrise, :therm0, p[:therm0])
set_parameter!(m, :sealevelrise, :gsic0, p[:gsic0])
set_parameter!(m, :sealevelrise, :gis0, p[:gis0])
set_parameter!(m, :sealevelrise, :ais0, p[:ais0])
set_parameter!(m, :sealevelrise, :therm_asym, p[:therm_asym])
set_parameter!(m, :sealevelrise, :gsic_asym, p[:gsic_asym])
set_parameter!(m, :sealevelrise, :gis_asym, p[:gis_asym])
set_parameter!(m, :sealevelrise, :ais_asym, p[:ais_asym])
set_parameter!(m, :sealevelrise, :thermrate, p[:thermrate])
set_parameter!(m, :sealevelrise, :gsicrate, p[:gsicrate])
set_parameter!(m, :sealevelrise, :gisrate, p[:gisrate])
set_parameter!(m, :sealevelrise, :aisrate, p[:aisrate])
set_parameter!(m, :sealevelrise, :slrthreshold, p[:slrthreshold])

# Run the one-component model
run(m)

# Extract the generated variables
ThermSLR    = m[:sealevelrise, :ThermSLR]
GSICSLR     = m[:sealevelrise, :GSICSLR]
GISSLR      = m[:sealevelrise, :GISSLR]
AISSLR      = m[:sealevelrise, :AISSLR]
TotSLR      = m[:sealevelrise, :TotSLR]

# Extract the true values
True_ThermSLR    = getparams(f, "B178:BI178", :all, "Base", T)
True_GSICSLR    = getparams(f, "B179:BI179", :all, "Base", T)
True_GISSLR    = getparams(f, "B180:BI180", :all, "Base", T)
True_AISSLR    = getparams(f, "B181:BI181", :all, "Base", T)
True_TotSLR    = getparams(f, "B182:BI182", :all, "Base", T)

# Test that the values are the same
@test maximum(abs, ThermSLR .- True_ThermSLR) ≈ 0. atol = Precision
@test maximum(abs, GSICSLR .- True_GSICSLR) ≈ 0. atol = Precision
@test maximum(abs, GISSLR .- True_GISSLR) ≈ 0. atol = Precision
@test maximum(abs, AISSLR .- True_AISSLR) ≈ 0. atol = Precision
@test maximum(abs, TotSLR .- True_TotSLR) ≈ 0. atol = Precision

end