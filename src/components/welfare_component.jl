@defcomp welfare begin
    CEMUTOTPER      = Variable(index=[time])    #Period utility
    PERIODU         = Variable(index=[time])    #One period utility function
    UTILITY         = Variable()                #Welfare Function

    CPC             = Parameter(index=[time])   #Per capita consumption (thousands 2005 USD per year)
    l               = Parameter(index=[time])   #Level of population and labor
    rr              = Parameter(index=[time])   #Average utility social discount rate
    elasmu          = Parameter()               #Elasticity of marginal utility of consumption
    scale1          = Parameter()               #Multiplicative scaling coefficient
    scale2          = Parameter()               #Additive scaling coefficient

    function run_timestep(p, v, d, t)
        #Define function for PERIODU
        v.PERIODU[t] = (1 / (1 - p.elasmu)) * (p.CPC[t] ^ (1 - p.elasmu)) + 1

        #Define function for CEMUTOTPER
        v.CEMUTOTPER[t] = v.PERIODU[t] * p.l[t] * p.rr[t]

        #Define function for UTILITY
        if t == TimestepIndex(40)
            v.UTILITY = 10 * p.scale1 * sum(v.CEMUTOTPER[TimestepIndex(1):TimestepIndex(40)]) + p.scale2
        end
    end
end
