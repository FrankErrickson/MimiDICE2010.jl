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

include("components/composites/SocioEconomics.jl")
include("components/composites/Climate.jl")
include("components/composites/Damages.jl")
include("components/composites/DICE2010.jl")

export construct_dice

# Allow these to be accessed by, e.g., EPA DICE model
const model_years = 2005:10:2595

function get_model(params=nothing; variant::Symbol = :DEFAULT, year::Union{Int, Nothing} = nothing)
    params_dict = params == nothing ? dice2010_excel_parameters() : params

    if variant == :DEFAULT 
        return get_model_default(p)
    elseif variant == :COMPOSITE 
        return get_model_composite(p)
    elseif variant == :SCC
        return get_model_scc(p; year = year)
    else
        error("Unknown model variant specification: ($variant).")
    end
end

function get_model_default(p)

    m = Model()
    set_dimension!(m, :time, model_years)

    #--------------------------------------------------------------------------
    # Add components in order
    #--------------------------------------------------------------------------

    add_comp!(m, grosseconomy)
    add_comp!(m, emissions)
    add_comp!(m, co2cycle)
    add_comp!(m, radiativeforcing)
    add_comp!(m, climatedynamics)
    add_comp!(m, sealevelrise)
    add_comp!(m, damages)
    add_comp!(m, neteconomy)
    add_comp!(m, welfare)

    #--------------------------------------------------------------------------
    # Make internal parameter connections
    #--------------------------------------------------------------------------

    # Socioeconomics
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)
    connect_param!(m, :emissions, :YGROSS, :grosseconomy, :YGROSS)
    
    # Climate
    connect_param!(m, :co2cycle, :E, :emissions, :E)
    connect_param!(m, :radiativeforcing, :MAT, :co2cycle, :MAT)
    connect_param!(m, :radiativeforcing, :MAT_final, :co2cycle, :MAT_final)
    connect_param!(m, :climatedynamics, :FORC, :radiativeforcing, :FORC)
    connect_param!(m, :sealevelrise, :TATM, :climatedynamics, :TATM)

    # Damages
    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :damages, :TotSLR, :sealevelrise, :TotSLR)
    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMFRAC, :damages, :DAMFRAC)
    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    #--------------------------------------------------------------------------
    # Set external parameter values 
    #--------------------------------------------------------------------------
    for (name, value) in params_dict
        set_param!(m, name, value)
    end

    return m
end

function get_model_composite(p)

    m = Model()
    set_dimension!(m, :time, model_years)

    add_comp!(m, DICE2010)  # DICE2010 composite component defined in src/components/composites/DICE2010.jl 

    # Set the external parameters now 
    # QUESTION: could we just use set_leftover_params for all of the following?

    # SocioEconomics external parameters 
    set_param!(m, :DICE2010, :al, p[:al])
    set_param!(m, :DICE2010, :l, p[:l])
    set_param!(m, :DICE2010, :gama, p[:gama])
    set_param!(m, :DICE2010, :dk, p[:dk])
    set_param!(m, :DICE2010, :k0, p[:k0])
    set_param!(m, :DICE2010, :sigma, p[:sigma])
    set_param!(m, :DICE2010, :MIU, p[:miubase])
    set_param!(m, :DICE2010, :etree, p[:etree])

    # Climate external parameters 
    set_param!(m, :DICE2010, :mat0, p[:mat0])
    set_param!(m, :DICE2010, :mat1, p[:mat1])
    set_param!(m, :DICE2010, :mu0, p[:mu0])
    set_param!(m, :DICE2010, :ml0, p[:ml0])
    set_param!(m, :DICE2010, :b12, p[:b12])
    set_param!(m, :DICE2010, :b23, p[:b23])
    set_param!(m, :DICE2010, :b11, p[:b11])
    set_param!(m, :DICE2010, :b21, p[:b21])
    set_param!(m, :DICE2010, :b22, p[:b22])
    set_param!(m, :DICE2010, :b32, p[:b32])
    set_param!(m, :DICE2010, :b33, p[:b33])
    set_param!(m, :DICE2010, :forcoth, p[:forcoth])
    set_param!(m, :DICE2010, :fco22x, p[:fco22x])
    # set_param!(m, :DICE2010, :fco22x, p[:fco22x])  # an instance where this parameter used to be set twice separately for different components
    set_param!(m, :DICE2010, :t2xco2, p[:t2xco2])
    set_param!(m, :DICE2010, :tatm0, p[:tatm0])
    set_param!(m, :DICE2010, :tatm1, p[:tatm1])
    set_param!(m, :DICE2010, :tocean0, p[:tocean0])
    set_param!(m, :DICE2010, :c1, p[:c1])
    set_param!(m, :DICE2010, :c3, p[:c3])
    set_param!(m, :DICE2010, :c4, p[:c4])
    set_param!(m, :DICE2010, :therm0, p[:therm0])
    set_param!(m, :DICE2010, :gsic0, p[:gsic0])
    set_param!(m, :DICE2010, :gis0, p[:gis0])
    set_param!(m, :DICE2010, :ais0, p[:ais0])
    set_param!(m, :DICE2010, :therm_asym, p[:therm_asym])
    set_param!(m, :DICE2010, :gsic_asym, p[:gsic_asym])
    set_param!(m, :DICE2010, :gis_asym, p[:gis_asym])
    set_param!(m, :DICE2010, :ais_asym, p[:ais_asym])
    set_param!(m, :DICE2010, :thermrate, p[:thermrate])
    set_param!(m, :DICE2010, :gsicrate, p[:gsicrate])
    set_param!(m, :DICE2010, :gisrate, p[:gisrate])
    set_param!(m, :DICE2010, :aisrate, p[:aisrate])
    set_param!(m, :DICE2010, :slrthreshold, p[:slrthreshold])

    # Damages external parameters
    set_param!(m, :DICE2010, :a1, p[:a1])
    set_param!(m, :DICE2010, :a2, p[:a2])
    set_param!(m, :DICE2010, :a3, p[:a3])
    set_param!(m, :DICE2010, :b1, p[:slrcoeff])
    set_param!(m, :DICE2010, :b2, p[:slrcoeffsq])
    set_param!(m, :DICE2010, :b3, p[:slrexp])
    set_param!(m, :DICE2010, :cost1, p[:cost1])
    # set_param!(m, :DICE2010, :MIU, p[:miubase])    # an instance where this parameter used to be set twice separately for different components
    set_param!(m, :DICE2010, :expcost2, p[:expcost2])
    set_param!(m, :DICE2010, :partfract, p[:partfract])
    set_param!(m, :DICE2010, :pbacktime, p[:pbacktime])
    set_param!(m, :DICE2010, :S, p[:savebase])
    # set_param!(m, :DICE2010, :l, p[:l])    # an instance where this parameter used to be set twice separately for different components
    # set_param!(m, :DICE2010, :l, p[:l])    # an instance where this parameter used to be set twice separately for different components
    set_param!(m, :DICE2010, :elasmu, p[:elasmu])
    set_param!(m, :DICE2010, :rr, p[:rr])
    set_param!(m, :DICE2010, :scale1, p[:scale1])
    set_param!(m, :DICE2010, :scale2, p[:scale2])

    return m
end

function get_model_scc(p; year::Union{Int, Nothing})
    m = Model()
    set_dimension!(m, :time, model_years)

    add_comp!(m, SCC_composite)  # SCC_composite composite component defined in src/components/composites/SCC_composite.jl 

    # Add the pulse of emissions
    time = Mimi.dimension(m, :time)
    marginal_emissions = zeros(length(time))
    marginal_emissions[time[year]] = 1.0        # 1 GtC
    set_param!(m, :SCC_composite, :add, marginal_emissions)

    # set the pulse_size parameter 
    set_param!(m, :SCC_composite, :pulse_size, 1e10 * 12/44)

    # Set the rest of the external parameters 
    set_leftover_params!(m, p)  #TBD if this would work
end

construct_dice = get_model # still export the old version of the function name

end #module