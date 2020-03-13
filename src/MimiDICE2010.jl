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
    p = params == nothing ? dice2010_excel_parameters() : params

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

function get_model_default(params_dict)

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

function get_model_composite(params_dict)

    m = Model()
    set_dimension!(m, :time, model_years)

    add_comp!(m, DICE2010)  # DICE2010 composite component defined in src/components/composites/DICE2010.jl 

    for (name, value) in params_dict
        set_param!(m, name, value)
    end

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