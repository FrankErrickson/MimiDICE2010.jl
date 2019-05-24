@defcomp anthoff_emmerling_welfare begin
    welfare = Variable(index=[time])
    cum_welfare = Variable(index=[time])
    marginal_welfare = Variable(index=[time])
    total_welfare = Variable()

    CPC = Parameter(index=[time])
    l = Parameter(index=[time])
    prtp = Parameter()
    temporal_inequality_aversion = Parameter()

    function run_timestep(p, v, d, t)
        cpc = p.CPC[t] * 1000.
        population = p.l[t] * 1_000_000
        v.welfare[t] = 10 * (p.temporal_inequality_aversion==1.0 ? log(cpc) : cpc^(1-p.temporal_inequality_aversion) / (1-p.temporal_inequality_aversion) ) * population * (1+p.prtp)^(-t.t+1) 

        v.cum_welfare[t] = t.t==1 ? v.welfare[t] : v.cum_welfare[t-1] + v.welfare[t]

        v.marginal_welfare[t] = (1+p.prtp)^(-t.t+1) * (1/cpc)^p.temporal_inequality_aversion

        if t.t == 40
            v.total_welfare = v.cum_welfare[t]
        end
    end
end
