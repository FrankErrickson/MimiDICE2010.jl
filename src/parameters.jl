const datafile = joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx")

"""
    read_params(f, range::String, count::Int, sheet::String="Base")

Get parameters from DICE2010 excel sheet.

`range` is a single cell or a range of cells in the excel sheet.
  Must be a cell reference of the form "A27" or a range "B56:B77".

`count` is the length of the time dimension; ignored if range
   refers to a single cell.

`sheet` is the name of the worksheet in the Excel file to read from.
  Defaults to "Base".

Examples:
    values = read_params(f, "B15:BI15", 40)   # read only the first 40 values

    value = read_params(f, "A27", sheet="Parameters")
    value = read_params(f, "A27:A27", sheet="Parameters") # same as above
"""
function read_params(f, range::String, T::Int=60; sheet::String="Base")
    data = readxl(f, "$(sheet)!$(range)")
    parts = split(range, ":")
    return (length(parts) == 1 || parts[1] == parts[2]) ? data : Vector{Float64}(data[1:T])
end

function dice2010_excel_parameters(filename=datafile; nsteps=nothing)
    p = Dict{Symbol,Any}()

    # the number of time-indexed values to read
    nsteps = nsteps == nothing ? length(2005:10:2595) : nsteps

    #Open DICE_2010 Excel file to read parameters
    f = openxl(filename)

    # Preferences
    p[:elasmu]  = read_params(f, "B19")               # Elasticity of marginal utility of consumption
    p[:rr]      = read_params(f, "B18:BI18", nsteps)       # Social time preference factor

    # Population and technology
    p[:gama]    = read_params(f, "B9")                # Capital elasticity in production function
    p[:l]       = read_params(f, "B27:BI27", nsteps)       # Population (millions)
    p[:dk]      = read_params(f, "B10")               # Depreciation rate on capital (per year)
    p[:k0]      = read_params(f, "B13")               # Initial capital value (trill 2005 USD)
    p[:al]      = read_params(f, "B21:BI21", nsteps)       # Level of total factor productivity

    # Emissions parameters
    p[:sigma]   = read_params(f, "B46:BI46", nsteps)
    p[:etree]   = read_params(f, "B52:BI52", nsteps)
    p[:MIU]     = read_params(f, "B133:BI133", nsteps)         # emissions control rate
    p[:S]       = read_params(f, "B132:BI132", nsteps) / 100   # savings rate

    # Carbon cycle
    p[:mat0]    = read_params(f, "B57")   # Initial Concentration in atmosphere 2000 (GtC)
    p[:mat1]    = read_params(f, "B58")   # Initial Concentration in atmosphere 2010 (GtC)
    p[:mu0]     = read_params(f, "B59")   # Initial Concentration in biosphere/shallow oceans (GtC)
    p[:ml0]     = read_params(f, "B60")   # Initial Concentration in deep oceans (GtC)

    # Flow parameters
    p[:b12] = read_params(f, "B64") / 100 # Carbon cycle transition matrix atmosphere to shallow ocean
    p[:b23] = read_params(f, "B67") / 100 # Carbon cycle transition matrix shallow to deep ocean

    # Parameters for long-run consistency of carbon cycle
    p[:b11] = read_params(f, "B62") / 100 # Carbon cycle transition matrix atmosphere to atmosphere
    p[:b21] = read_params(f, "B63") / 100 # Carbon cycle transition matrix biosphere/shallow oceans to atmosphere
    p[:b22] = read_params(f, "B65") / 100 # Carbon cycle transition matrix shallow ocean to shallow oceans
    p[:b32] = read_params(f, "B66") / 100 # Carbon cycle transition matrix deep ocean to shallow ocean
    p[:b33] = read_params(f, "B68") / 100 # Carbon cycle transition matrix deep ocean to deep oceans

    # Climate model parameters
    p[:t2xco2]  = read_params(f, "B76")   # Equilibrium temp impact (oC per doubling CO2)
    p[:tatm0]   = read_params(f, "B73")   # Initial lower stratum temp change (C from 1900)
    p[:tatm1]   = read_params(f, "C73")   # Initial atmospheric temp change 2015 (C from 1900)
    p[:tocean0] = read_params(f, "B74")   # Initial lower stratum temp change (C from 1900)

    # Transient TSC Correction ("Speed of Adjustment Parameter")
    p[:c1]      = read_params(f, "B75")   # Climate equation coefficient for upper level
    p[:c3]      = read_params(f, "B78")   # Transfer coefficient upper to lower stratum
    p[:c4]      = read_params(f, "B79")   # Transfer coefficient for lower level
    p[:fco22x]  = read_params(f, "B77")   # Forcings of equilibrium CO2 doubling (Wm-2)

    # Climate damage parameters
    p[:a1] = read_params(f, "B33")   # Damage coefficient
    p[:a2] = read_params(f, "B34")   # Damage quadratic term
    p[:a3] = read_params(f, "B35")   # Damage exponent

    # Abatement cost
    p[:expcost2]    = read_params(f, "B44")               # Exponent of control cost function
    p[:pbacktime]   = read_params(f, "B42:BI42", nsteps)       # backstop price
    # Adjusted cost for backstop (or: "Abatement cost function coefficient")
    p[:cost1]       = read_params(f, "B37:BI37", nsteps)

    # Scaling and inessential parameters
    p[:scale1] = read_params(f, "B88")    # Multiplicative scaling coefficient
    p[:scale2] = read_params(f, "B89")    # Additive scaling coefficient

    # Exogenous forcing for other greenhouse gases
    p[:forcoth] = read_params(f, "B70:BI70", nsteps)

    # Fraction of emissions in control regime
    p[:partfract] = read_params(f, "B82:BI82", nsteps)


    # SLR Parameters

    p[:b1]          = read_params(f, "B51", sheet="Parameters")
    p[:b2]          = read_params(f, "B52", sheet="Parameters")
    p[:b3]          = read_params(f, "B53", sheet="Parameters")

    p[:therm0]      = read_params(f, "B178") # meters above 2000
    p[:gsic0]       = read_params(f, "B179")
    p[:gis0]        = read_params(f, "B180")
    p[:ais0]        = read_params(f, "B181")

    p[:therm_asym]  = read_params(f, "B173")
    p[:gsic_asym]   = read_params(f, "B174")
    p[:gis_asym]    = read_params(f, "B175")
    p[:ais_asym]    = read_params(f, "B176")

    p[:thermrate]   = read_params(f, "C173")
    p[:gsicrate]    = read_params(f, "C174")
    p[:gisrate]     = read_params(f, "C175")
    p[:aisrate]     = read_params(f, "C176")

    p[:slrthreshold] = read_params(f, "D176")

    return p
end
