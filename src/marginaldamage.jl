"""
compute_scc(m::Model=get_model(); year::Int = nothing, last_year::Int = 2595), prtp::Float64 = 0.03)

Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiDICE2010 model. 
If no model is provided, the default model from MimiDICE2010.get_model() is used.
Constant discounting is used from the specified pure rate of time preference `prtp`.

TODO:
- do we want to implement interpolation if the ask for an SCC value between the timestep values? currently errors
- do we want to implement ramsey discounting, i.e. offer the eta keyword argument as well? 
- should marginal damages be a step function across the ten year timesteps to be used by the SCC? or should I lineraly interpolate to get annual marginal emissions?
"""
function compute_scc(m::Model=get_model(); year::Union{Int, Nothing} = nothing, last_year::Int = model_years[end], prtp::Float64 = 0.015, temporal_inequality_aversion::Float64=1.45)
    year === nothing ? error("Must specify an emission year. Try `compute_scc(m, year=2015)`.") : nothing
    !(last_year in model_years) ? error("Invlaid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:10:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    add_comp!(m, anthoff_emmerling_welfare)
    connect_param!(m, :anthoff_emmerling_welfare, :CPC, :neteconomy, :CPC)
    connect_param!(m.md, :anthoff_emmerling_welfare, :l, :l)
    set_param!(m, :anthoff_emmerling_welfare, :prtp, prtp)
    set_param!(m, :anthoff_emmerling_welfare, :temporal_inequality_aversion, temporal_inequality_aversion)

    mm = get_marginal_model(m; year = year)

    return _compute_scc(mm, year=year, last_year=last_year, prtp=prtp)
end

"""
compute_scc_mm(m::Model=get_model(); year::Int = nothing, last_year::Int = 2595, prtp::Float64 = 0.03)

Returns a NamedTuple (scc=scc, mm=mm) of the social cost of carbon and the MarginalModel used to compute it.
Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiDICE2010 model. 
If no model is provided, the default model from MimiDICE2010.get_model() is used.
Constant discounting is used from the specified pure rate of time preference `prtp`.
"""
function compute_scc_mm(m::Model=get_model(); year::Union{Int, Nothing} = nothing, last_year::Int = model_years[end], prtp::Float64 = 0.03)
    year === nothing ? error("Must specify an emission year. Try `compute_scc_mm(m, year=2015)`.") : nothing
    !(last_year in model_years) ? error("Invlaid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:10:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    mm = get_marginal_model(m; year = year)
    scc = _compute_scc(mm; year=year, last_year=last_year, prtp=prtp)
    
    return (scc = scc, mm = mm)
end

# helper function for computing SCC from a MarginalModel, not to be exported or advertised to users
function _compute_scc(mm::MarginalModel; year::Int, last_year::Int, prtp::Float64)
    ntimesteps = findfirst(isequal(last_year), model_years)     # Will run through the timestep of the specified last_year 
    run(mm, ntimesteps=ntimesteps)

    time = Mimi.dimension(mm.base, :time)

    # We need to take the negative to convert from impact to damage
    scc_in_welfare_units = -mm[:anthoff_emmerling_welfare, :total_welfare] * 12 / 44
    scc = scc_in_welfare_units / mm.base[:anthoff_emmerling_welfare, :marginal_welfare][time[year]]

    return scc
end

"""
get_marginal_model(m::Model = get_model(); year::Int = nothing)

Creates a Mimi MarginalModel where the provided m is the base model, and the marginal model has additional emissions of CO2 in year `year`.
If no Model m is provided, the default model from MimiDICE2010.get_model() is used as the base model.
"""
function get_marginal_model(m::Model=get_model(); year::Union{Int, Nothing} = nothing)
    year === nothing ? error("Must specify an emission year. Try `get_marginal_model(m, year=2015)`.") : nothing
    !(year in model_years) ? error("Cannot add marginal emissions in $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    mm = create_marginal_model(m, 10.0^10)
    add_marginal_emissions!(mm.marginal, year)

    return mm
end

"""
Adds a marginal emission component to year m which adds 1Gt of additional C emissions per year for ten years starting in the specified `year`.
"""
function add_marginal_emissions!(m::Model, year::Int) 
    add_comp!(m, Mimi.adder, :marginalemission, before=:co2cycle)

    time = Mimi.dimension(m, :time)
    addem = zeros(length(time))
    addem[time[year]] = 1.0     # 1 GtC per year for ten years

    set_param!(m, :marginalemission, :add, addem)
    connect_param!(m, :marginalemission, :input, :emissions, :E)
    connect_param!(m, :co2cycle, :E, :marginalemission, :output)
end



# Old available function
function getmarginal_dice_models(;emissionyear=2015)

    DICE = get_model()
    run(DICE)

    mm = MarginalModel(DICE)
    m1 = mm.base
    m2 = mm.marginal

    add_comp!(m2, Mimi.adder, :marginalemission, before=:co2cycle)

    time = Mimi.dimension(m1, :time)
    addem = zeros(length(time))
    addem[time[emissionyear]] = 1.0

    set_param!(m2, :marginalemission, :add, addem)
    connect_param!(m2, :marginalemission, :input, :emissions, :E)
    connect_param!(m2, :co2cycle, :E, :marginalemission, :output)

    run(m1)
    run(m2)

    return m1, m2
end
