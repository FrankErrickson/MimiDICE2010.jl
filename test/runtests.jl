using Test
using Mimi
using MimiDICE2010
using ExcelReaders
using DataFrames
using CSVFiles

using MimiDICE2010: read_params, dice2010_excel_parameters

@testset "mimi-dice-2010" begin

#------------------------------------------------------------------------------
#   1. Run the independent component tests
#------------------------------------------------------------------------------

@testset "dice2010-components" begin

include("test_climatedynamics.jl")
include("test_co2cycle.jl")
include("test_damages.jl")
include("test_emissions.jl")
include("test_grosseconomy.jl")
include("test_neteconomy.jl")
include("test_radiativeforcing.jl")
include("test_sealevelrise.jl")
include("test_welfare.jl")

end #dice2010-components testset


#------------------------------------------------------------------------------
#   2. Run tests on the whole model
#------------------------------------------------------------------------------

@testset "dice2010-model" begin

Precision = 1.0e-11
T = 60
f = openxl(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))

m = MimiDICE2010.get_model()
run(m)

# Climate dynamics tests

TATM    = m[:climatedynamics, :TATM]
TOCEAN  = m[:climatedynamics, :TOCEAN]

True_TATM   = read_params(f, "B121:BI121", T)
True_TOCEAN = read_params(f, "B123:BI123", T)

@test maximum(abs, TATM .- True_TATM) ≈ 0. atol = Precision
@test maximum(abs, TOCEAN .- True_TOCEAN) ≈ 0. atol = Precision


# CO2 Cycle tests

MAT     = m[:co2cycle, :MAT]
MAT_final   = m[:co2cycle, :MAT_final]
ML      = m[:co2cycle, :ML]
MU      = m[:co2cycle, :MU]

True_MAT    = read_params(f, "B112:BI112", T)
True_MAT_final  = read_params(f, "BJ112")
True_ML     = read_params(f, "B115:BI115", T)
True_MU     = read_params(f, "B114:BI114", T)

@test maximum(abs, MAT .- True_MAT) ≈ 0. atol = Precision
@test abs(MAT_final - True_MAT_final) ≈ 0. atol = Precision
@test maximum(abs, ML .- True_ML) ≈ 0. atol = Precision
@test maximum(abs, MU .- True_MU) ≈ 0. atol = Precision


# Damages test

DAMFRAC = m[:damages, :DAMFRAC]
True_DAMFRAC    = read_params(f, "B93:BI93", T)
@test maximum(abs, DAMFRAC .- True_DAMFRAC) ≈ 0. atol = Precision


# Emissions tests

CCA     = m[:emissions, :CCA]
E       = m[:emissions, :E]
EIND    = m[:emissions, :EIND]

True_CCA    = read_params(f, "B117:BI117", T)
True_E      = read_params(f, "B109:BI109", T)
True_EIND   = read_params(f, "B110:BI110", T)

@test maximum(abs, CCA .- True_CCA) ≈ 0. atol = Precision
@test maximum(abs, E .- True_E) ≈ 0. atol = Precision
@test maximum(abs, EIND .- True_EIND) ≈ 0. atol = Precision


# Gross Economy tests

K       = m[:grosseconomy, :K]
YGROSS  = m[:grosseconomy, :YGROSS]

True_K      = read_params(f, "B102:BI102", T)
True_YGROSS = read_params(f, "B92:BI92", T)

@test maximum(abs, K .- True_K) ≈ 0. atol = 3.0e-11 # Relax the precision just for this variable
@test maximum(abs, YGROSS .- True_YGROSS) ≈ 0. atol = Precision


# Net Economy tests

ABATECOST   = m[:neteconomy, :ABATECOST]
C           = m[:neteconomy, :C]
CPC         = m[:neteconomy, :CPC]
CPRICE      = m[:neteconomy, :CPRICE]
I           = m[:neteconomy, :I]
Y           = m[:neteconomy, :Y]
YNET        = m[:neteconomy, :YNET]

True_ABATECOST  = read_params(f, "B97:BI97", T)
True_C          = read_params(f, "B125:BI125", T)
True_CPC        = read_params(f, "B126:BI126", T)
True_CPRICE     = read_params(f, "B134:BI134", T)
True_I          = read_params(f, "B101:BI101", T)
True_Y          = read_params(f, "B98:BI98", T)
True_YNET       = read_params(f, "B95:BI95", T)

@test maximum(abs, ABATECOST .- True_ABATECOST) ≈ 0. atol = Precision
@test maximum(abs, C .- True_C) ≈ 0. atol = Precision
@test maximum(abs, CPC .- True_CPC) ≈ 0. atol = Precision
@test maximum(abs, CPRICE .- True_CPRICE) ≈ 0. atol = Precision
@test maximum(abs, I .- True_I) ≈ 0. atol = Precision
@test maximum(abs, Y .- True_Y) ≈ 0. atol = Precision
@test maximum(abs, YNET .- True_YNET) ≈ 0. atol = Precision


# Radiative Forcing test

FORC = m[:radiativeforcing, :FORC]
True_FORC    = read_params(f, "B122:BI122", T)
@test maximum(abs, FORC .- True_FORC) ≈ 0. atol = Precision


# Sea Level Rise tests

ThermSLR    = m[:sealevelrise, :ThermSLR]
GSICSLR     = m[:sealevelrise, :GSICSLR]
GISSLR      = m[:sealevelrise, :GISSLR]
AISSLR      = m[:sealevelrise, :AISSLR]
TotSLR      = m[:sealevelrise, :TotSLR]

True_ThermSLR    = read_params(f, "B178:BI178", T)
True_GSICSLR    = read_params(f, "B179:BI179", T)
True_GISSLR    = read_params(f, "B180:BI180", T)
True_AISSLR    = read_params(f, "B181:BI181", T)
True_TotSLR    = read_params(f, "B182:BI182", T)

@test maximum(abs, ThermSLR .- True_ThermSLR) ≈ 0. atol = Precision
@test maximum(abs, GSICSLR .- True_GSICSLR) ≈ 0. atol = Precision
@test maximum(abs, GISSLR .- True_GISSLR) ≈ 0. atol = Precision
@test maximum(abs, AISSLR .- True_AISSLR) ≈ 0. atol = Precision
@test maximum(abs, TotSLR .- True_TotSLR) ≈ 0. atol = Precision


# Welfare tests

CEMUTOTPER  = m[:welfare, :CEMUTOTPER]
PERIODU     = m[:welfare, :PERIODU]
UTILITY     = m[:welfare, :UTILITY]

True_CEMUTOTPER    = read_params(f, "B129:BI129", T)
True_PERIODU    = read_params(f, "B128:BI128", T)
True_UTILITY    = read_params(f, "B130")

@test maximum(abs, CEMUTOTPER .- True_CEMUTOTPER) ≈ 0. atol = Precision
@test maximum(abs, PERIODU .- True_PERIODU) ≈ 0. atol = Precision
@test abs(UTILITY - True_UTILITY) ≈ 0. atol = Precision

end #dice-2010 testset

#------------------------------------------------------------------------------
#   3. Run tests to make sure integration version (Mimi v0.5.0)
#   values match Mimi 0.4.0 values
#------------------------------------------------------------------------------

@testset "dice2010-integration" begin

Precision = 1.0e-11
nullvalue = -999.999
T = 60

m = MimiDICE2010.get_model()
run(m)

for c in map(name, Mimi.compdefs(m)), v in Mimi.variable_names(m, c)

    #load data for comparison
    filepath = joinpath(@__DIR__, "../data/validation_data_v040/$c-$v.csv")
    results = m[c, v]

    df = load(filepath) |> DataFrame
    if typeof(results) <: Number
        validation_results = df[1,1]

    else
        validation_results = convert(Matrix, df)

        #remove NaNs
        results[ismissing.(results)] .= nullvalue
        results[isnan.(results)] .= nullvalue
        validation_results[ismissing.(validation_results)] .= nullvalue
        validation_results[isnan.(validation_results)] .= nullvalue

        #match dimensions
        if size(validation_results,1) == 1
            validation_results = validation_results'
        end

    end
    @test results ≈ validation_results atol = Precision

end #for loop

end #dice2010-integration testset

#------------------------------------------------------------------------------
#   4. Test standard api functions and SCC functions
#------------------------------------------------------------------------------

@testset "Standard API functions" begin

m = MimiDICE2010.get_model()
run(m)

# Test the errors
@test_throws ErrorException MimiDICE2010.compute_scc()  # test that it errors if you don't specify a year
@test_throws ErrorException MimiDICE2010.compute_scc(year=2020)  # test that it errors if the year isn't in the time index
@test_throws ErrorException MimiDICE2010.compute_scc(last_year=2300)  # test that it errors if the last_year isn't in the time index
@test_throws ErrorException MimiDICE2010.compute_scc(year=2105, last_year=2100)  # test that it errors if the year is after last_year

# Test the SCC
scc1 = MimiDICE2010.compute_scc(year=2015)
@test scc1 isa Float64

# Test that it's smaller with a shorter horizon
scc2 = MimiDICE2010.compute_scc(year=2015, last_year=2295)
@test scc2 < scc1

# Test that it's smaller with a larger prtp
scc3 = MimiDICE2010.compute_scc(year=2015, last_year=2295, prtp=0.02)
@test scc3 < scc2

# Test with a modified model
m = MimiDICE2010.get_model()
update_param!(m, :t2xco2, 5)
scc4 = MimiDICE2010.compute_scc(m, year=2015)
@test scc4 > scc1   # Test that a higher value of climate sensitivty makes the SCC bigger

# Test compute_scc_mm
result = MimiDICE2010.compute_scc_mm(year=2035)
@test result.scc isa Float64
@test result.mm isa Mimi.MarginalModel


end

#------------------------------------------------------------------------------
#   5. Validate Composite Model against Flat Model
#------------------------------------------------------------------------------
@testset "composite validation" begin 

include("test_composite_validation.jl")

end # composite validation testset

end # mimi-dice-2010 testset

nothing