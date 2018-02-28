using ExcelReaders
include("helpers.jl")

function getdice2010excelparameters(filename)
    p = Dict{Symbol,Any}()

    T = 60

    #Open DICE_2010 Excel file to read parameters
    f = openxl(filename)

    # Preferences
    p[:prstp] = 0.015   # Initial rate of social time preference per year
    p[:elasmu] = 1.5    # Elasticity of marginal utility of consumption
    rr0 = 1 #Initial Social Time Preference Factor
    p[:rr] = rr

    # Population and technology
    p[:gama] = 0.300    # Capital elasticity in production function
    p[:l] = readxl(f, "Base!B27:BI27")
    p[:dk] = 0.100      # Depreciation rate on capital (per year)
    p[:k0] = 97.3       # Initial capital value (trill 2005 USD)
    p[:al] = readxl(f, "Base!B21:BI21")     #Level of total factor productivity

    # Emissions parameters
    p[:sigma] = readxl(f, "Base!B46:BI46")
    p[:etree] = readxl(f, "Base!B52:BI52")
    p[:miubase] = readxl(f, "Base!B133:BI133")  # emissions control rate
    p[:savebase] = readxl(f, "Base!B132:BI132") / 100   # savings rate

    # Carbon cycle
    p[:mat0] = 787.0    # Initial Concentration in atmosphere 2010 (GtC)
    p[:mat1] =  829.0
    p[:mu0] = 1600.     # Initial Concentration in upper strata 2010 (GtC)
    p[:ml0] = 10010.    # Initial Concentration in lower strata 2010 (GtC)

    # Flow parameters
    p[:b12] = 12.0/100  # Carbon cycle transition matrix atmosphere to shallow ocean
    p[:b23] = 0.5/100   # Carbon cycle transition matrix shallow to deep ocean

    # Parameters for long-run consistency of carbon cycle
    p[:b11] = 88.0/100      # Carbon cycle transition matrix atmosphere to atmosphere 
    p[:b21] = 4.704/100     # Carbon cycle transition matrix biosphere/shallow oceans to atmosphere        
    p[:b22] = 94.796/100    # Carbon cycle transition matrix shallow ocean to shallow oceans              
    p[:b32] = 0.075/100     # Carbon cycle transition matrix deep ocean to shallow ocean                    
    p[:b33] = 99.925/100    # Carbon cycle transition matrix deep ocean to deep oceans                  

    # Climate model parameters
    p[:t2xco2] = 3.2    # Equilibrium temp impact (oC per doubling CO2)
    p[:tatm0] = 0.0068  # Initial lower stratum temp change (C from 1900)
    p[:tatm1] = 0.98    # Initial atmospheric temp change 2015 (C from 1900)
    p[:tocean0] = .0068 # Initial lower stratum temp change (C from 1900)

    # Transient TSC Correction ("Speed of Adjustment Parameter")
    p[:c1] = 0.208  # Climate equation coefficient for upper level
    p[:c3] = 0.310  # Transfer coefficient upper to lower stratum
    p[:c4] = 0.05   # Transfer coefficient for lower level
    p[:fco22x] = 3.8    # Forcings of equilibrium CO2 doubling (Wm-2)
    #lam = fco22x/ t2xco2

    # Climate damage parameters
    p[:a1] = 0.0000816191097385324  # Damage intercept
    p[:a2] = 0.00204625800317896    # Damage quadratic term 
    p[:a3] = 2.00                   # Damage exponent  

    # Abatement cost
    p[:expcost2] = 2.8  # Exponent of control cost function 
    p[:pbacktime] = readxl(f, "Base!B42:BI42")  # backstop price

    # Adjusted cost for backstop
    p[:cost1] = cost1

    # Participiation parameters
        # ???
    
    # Availability of fossil fuels
    p[:fosslim] = 6000. #        Maximum cumulative extraction fossil fuels (GtC)
    
    # Scaling and inessential parameters
    p[:scale1] = 0.0165977353994452 # Multiplicative scaling coefficient
    p[:scale2] = -2941.79815693009  # Additive scaling coefficient

    p[:optlrsav] = 22.9542700436767/100

    # Exogenous forcing for other greenhouse gases
    p[:forcoth] = forcoth
    
    # Fraction of emissions in control regime
    p[:partfract] = [1.0 for i in 1:T]
    
    # ???
    p[:alpha] = [1.0 for i in 1:T]


    #SLR Parameters

    p[:slrcoeff] = readxl(f, "Parameters!B51:B51")[1]
    p[:slrcoeffsq] = readxl(f, "Parameters!B52:B52")[1]
    p[:slrexp] = readxl(f, "Parameters!B53:B53")[1]

    p[:therm0] = readxl(f, "Base!B178:B178")[1] #meters above 2000
    p[:gsic0] = readxl(f, "Base!B179:B179")[1]
    p[:gis0] = readxl(f, "Base!B180:B180")[1]
    p[:ais0] = readxl(f, "Base!B181:B181")[1]

    p[:thermslr] = readxl(f, "Base!B173:B173")[1]
    p[:gsicslr] = readxl(f, "Base!B174:B174")[1]
    p[:gisslr] = readxl(f, "Base!B175:B175")[1]
    p[:aisslr] = readxl(f, "Base!B176:B176")[1]

    p[:thermrate] = readxl(f, "Base!C173:C173")[1]
    p[:gsicrate] = readxl(f, "Base!C174:C174")[1]
    p[:gisrate] = readxl(f, "Base!C175:C175")[1]
    p[:aisrate] = readxl(f, "Base!C176:C176")[1]

    p[:slrthreshold] = readxl(f, "Base!D176:D176")[1]

    return p
end
