using Mimi


@defcomp climatedynamics begin
    TATM    = Variable(index=[time])    #Increase in temperature of atmosphere (degrees C from 1900)
    TOCEAN  = Variable(index=[time])    #Increase in temperature of lower oceans (degrees C from 1900)

    FORC    = Parameter(index=[time])   #Increase in radiative forcing (watts per m2 from 1900)
    fco22x  = Parameter()               #Forcings of equilibrium CO2 doubling (Wm-2)
    t2xco2  = Parameter()               #Equilibrium temp impact (oC per doubling CO2)
    tatm0   = Parameter()               #Initial atmospheric temp change (C from 1900) in 2005
    tatm1   = Parameter()               #Initial atmospheric temp change (C from 1900) in 2015
    tocean0 = Parameter()               #Initial lower stratum temp change (C from 1900)

    # Transient TSC Correction ("Speed of Adjustment Parameter")
    c1 = Parameter()                    #Speed of adjustment parameter for atmospheric temperature
    c3 = Parameter()                    #Coefficient of heat loss from atmosphere to oceans
    c4 = Parameter()                    #Coefficient of heat gain by deep oceans.

    # function run_timestep(p, v, d, t)
    #     #Define function for TATM
    #     if t==1
    #         v.TATM[t] = p.tatm0
    #     elseif t==2
    #         v.TATM[t] = p.tatm1
    #     else
    #         v.TATM[t] = v.TATM[t-1] + p.c1 * ((p.FORC[t] - (p.fco22x/p.t2xco2) * v.TATM[t-1]) - (p.c3 * (v.TATM[t-1] - v.TOCEAN[t-1])))
    #     end

    #     #Define function for TOCEAN
    #     if t==1
    #         v.TOCEAN[t] = p.tocean0
    #     else
    #         v.TOCEAN[t] = v.TOCEAN[t-1] + p.c4 * (v.TATM[t-1] - v.TOCEAN[t-1])
    #     end
    # end

    function run_timestep(p, v, d, t)
        # Define functions for TATM and TOCEAN
        if t == 1
            v.TATM[t] = p.tatm0
            v.TOCEAN[t] = p.tocean0
        else
            prior_tatm = v.TATM[t-1]
            prior_tocean = v.TOCEAN[t-1]

            if t==2
                v.TATM[t] = p.tatm1
            else
                v.TATM[t] = prior_tatm + p.c1 * ((p.FORC[t] - (p.fco22x/p.t2xco2) * prior_tatm) - (p.c3 * (prior_tatm - prior_tocean)))
            end

            v.TOCEAN[t] = prior_tocean + p.c4 * (prior_tatm - prior_tocean)
        end
    end
end
