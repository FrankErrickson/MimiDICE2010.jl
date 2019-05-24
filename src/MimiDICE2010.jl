module MimiDICE2010

using Mimi
using ExcelReaders

include("parameters.jl")
include("marginaldamage.jl")

include("components/grosseconomy_component.jl")
include("components/emissions_component.jl")
include("components/co2cycle_component.jl")
include("components/radiativeforcing_component.jl")
include("components/climatedynamics_component.jl")
include("components/sealevelrise_component.jl")
include("components/damages_component.jl")
include("components/neteconomy_component.jl")
include("components/welfare_component.jl")
include("components/AEwelfare.jl")

export construct_dice

# Allow these to be accessed by, e.g., EPA DICE model
const model_years = 2005:10:2595

function get_model(params=nothing)
    p = params == nothing ? dice2010_excel_parameters() : params

    m = Model()
    set_dimension!(m, :time, model_years)

    add_comp!(m, grosseconomy)
    add_comp!(m, emissions)
    add_comp!(m, co2cycle)
    add_comp!(m, radiativeforcing)
    add_comp!(m, climatedynamics)
    add_comp!(m, sealevelrise)
    add_comp!(m, damages)
    add_comp!(m, neteconomy)
    add_comp!(m, welfare)

    #GROSS ECONOMY COMPONENT
    set_param!(m, :grosseconomy, :al, p[:al])
    set_param!(m, :grosseconomy, :l, p[:l])
    set_param!(m, :grosseconomy, :gama, p[:gama])
    set_param!(m, :grosseconomy, :dk, p[:dk])
    set_param!(m, :grosseconomy, :k0, p[:k0])

    # Note: offset=1 => dependence is on on prior timestep, i.e., not a cycle
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)

    #EMISSIONS COMPONENT
    set_param!(m, :emissions, :sigma, p[:sigma])
    set_param!(m, :emissions, :MIU, p[:miubase])
    set_param!(m, :emissions, :etree, p[:etree])

    connect_param!(m, :emissions, :YGROSS, :grosseconomy, :YGROSS)


    #CO2 CYCLE COMPONENT
    set_param!(m, :co2cycle, :mat0, p[:mat0])
    set_param!(m, :co2cycle, :mat1, p[:mat1])
    set_param!(m, :co2cycle, :mu0, p[:mu0])
    set_param!(m, :co2cycle, :ml0, p[:ml0])
    set_param!(m, :co2cycle, :b12, p[:b12])
    set_param!(m, :co2cycle, :b23, p[:b23])
    set_param!(m, :co2cycle, :b11, p[:b11])
    set_param!(m, :co2cycle, :b21, p[:b21])
    set_param!(m, :co2cycle, :b22, p[:b22])
    set_param!(m, :co2cycle, :b32, p[:b32])
    set_param!(m, :co2cycle, :b33, p[:b33])

    connect_param!(m, :co2cycle, :E, :emissions, :E)


    #RADIATIVE FORCING COMPONENT
    set_param!(m, :radiativeforcing, :forcoth, p[:forcoth])
    set_param!(m, :radiativeforcing, :fco22x, p[:fco22x])

    connect_param!(m, :radiativeforcing, :MAT, :co2cycle, :MAT)
    connect_param!(m, :radiativeforcing, :MAT_final, :co2cycle, :MAT_final)


    #CLIMATE DYNAMICS COMPONENT
    set_param!(m, :climatedynamics, :fco22x, p[:fco22x])
    set_param!(m, :climatedynamics, :t2xco2, p[:t2xco2])
    set_param!(m, :climatedynamics, :tatm0, p[:tatm0])
    set_param!(m, :climatedynamics, :tatm1, p[:tatm1])
    set_param!(m, :climatedynamics, :tocean0, p[:tocean0])
    set_param!(m, :climatedynamics, :c1, p[:c1])
    set_param!(m, :climatedynamics, :c3, p[:c3])
    set_param!(m, :climatedynamics, :c4, p[:c4])

    connect_param!(m, :climatedynamics, :FORC, :radiativeforcing, :FORC)


    # SEA LEVEL RISE COMPONENT
    set_param!(m, :sealevelrise, :therm0, p[:therm0])
    set_param!(m, :sealevelrise, :gsic0, p[:gsic0])
    set_param!(m, :sealevelrise, :gis0, p[:gis0])
    set_param!(m, :sealevelrise, :ais0, p[:ais0])
    set_param!(m, :sealevelrise, :therm_asym, p[:therm_asym])
    set_param!(m, :sealevelrise, :gsic_asym, p[:gsic_asym])
    set_param!(m, :sealevelrise, :gis_asym, p[:gis_asym])
    set_param!(m, :sealevelrise, :ais_asym, p[:ais_asym])
    set_param!(m, :sealevelrise, :thermrate, p[:thermrate])
    set_param!(m, :sealevelrise, :gsicrate, p[:gsicrate])
    set_param!(m, :sealevelrise, :gisrate, p[:gisrate])
    set_param!(m, :sealevelrise, :aisrate, p[:aisrate])
    set_param!(m, :sealevelrise, :slrthreshold, p[:slrthreshold])

    connect_param!(m, :sealevelrise, :TATM, :climatedynamics, :TATM)


    #DAMAGES COMPONENT
    set_param!(m, :damages, :a1, p[:a1])
    set_param!(m, :damages, :a2, p[:a2])
    set_param!(m, :damages, :a3, p[:a3])
    set_param!(m, :damages, :b1, p[:slrcoeff])
    set_param!(m, :damages, :b2, p[:slrcoeffsq])
    set_param!(m, :damages, :b3, p[:slrexp])

    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :damages, :TotSLR, :sealevelrise, :TotSLR)


    #NET ECONOMY COMPONENT
    set_param!(m, :neteconomy, :cost1, p[:cost1])
    set_param!(m, :neteconomy, :MIU, p[:miubase])
    set_param!(m, :neteconomy, :expcost2, p[:expcost2])
    set_param!(m, :neteconomy, :partfract, p[:partfract])
    set_param!(m, :neteconomy, :pbacktime, p[:pbacktime])
    set_param!(m, :neteconomy, :S, p[:savebase])
    set_param!(m, :neteconomy, :l, p[:l])

    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    #connect_param!(m, :neteconomy, :DAMAGES, :damages, :DAMAGES)
    connect_param!(m, :neteconomy, :DAMFRAC, :damages, :DAMFRAC)


    #WELFARE COMPONENT
    set_param!(m, :welfare, :l, p[:l])
    set_param!(m, :welfare, :elasmu, p[:elasmu])
    set_param!(m, :welfare, :rr, p[:rr])
    set_param!(m, :welfare, :scale1, p[:scale1])
    set_param!(m, :welfare, :scale2, p[:scale2])

    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    return m
end

construct_dice = get_model # still export the old version of the function name

end #module