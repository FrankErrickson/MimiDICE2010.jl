
@defcomp SCC_calculation begin
    # TBD which variables are needed for this depending on how we want to do it
    base_utility = Parameter()
    marginal_utility = Parameter()

    pulse_size = Parameter()

    SCC = Variable()

    function run_timestep(p, v, d, t)
        if is_final(t)
            v.SCC = (p.base_utility - p.marginal_utility) / pulse_size
        end
    end
end

@defcomposite SCC_composite begin

    # Add child components
    Component(DICE2010, :base)
    Component(adder, :CO2_pulse)    # does this need to be added before the marginal composite?
    Component(DICE2010, :marginal)
    Component(SCC_calculation)

    # Resolve parameter namespace collisions
    #   TBD: this would error for all DICE2010 external parameters because "base" and "marginal" are the same

    # Make internal connections
    CO2_pulse.input                     = marginal.SocioEconomics.emissions.E
    marginal.Climate.co2cycle.E         = CO2_pulse.output          # This doesn't work with our current design; we would be overriding the internal connection within the Climate composite component for the E parameter
    SCC_calculation.base_utility        = base.UTILITY
    SCC_calculation.marginal_utility    = marginal.UTILITY

    # Export variables
    SCC = SCC_calculation.SCC

end
