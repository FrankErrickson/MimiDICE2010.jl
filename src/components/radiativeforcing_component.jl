using Mimi


@defcomp radiativeforcing begin
    FORC      = Variable(index=[time])   #Increase in radiative forcing (watts per m2 from 1900)

    forcoth   = Parameter(index=[time])  #Exogenous forcing for other greenhouse gases
    MAT       = Parameter(index=[time])  #Carbon concentration increase in atmosphere (GtC from 1750)
    MAT61     = Parameter()              #MAT calculation one timestep further than the model's index   
    fco22x    = Parameter()              #Forcings of equilibrium CO2 doubling (Wm-2)

    function run_timestep(p, v, d, t)
        #Define function for FORC
        #TODO: change to a !is_timestep(t, 60) when porting to 1.0
        if t.t != 60
            v.FORC[t] = p.fco22x * (log((((p.MAT[t] + p.MAT[t+1]) / 2) + 0.000001)/596.4)/log(2)) + p.forcoth[t]
        #TODO: change to a is_timestep(t, 60) when porting to 1.0
        elseif t.t == 60
            # need to use MAT61, calculated one step further 
            v.FORC[t] = p.fco22x * (log((((p.MAT[t] + p.MAT61) / 2) + 0.000001)/596.4)/log(2)) + p.forcoth[t]
        end
    end
end
