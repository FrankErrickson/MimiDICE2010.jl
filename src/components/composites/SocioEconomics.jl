
@defcomposite SocioEconomics begin

    # Add child components
    component(grosseconomy) 
    component(emissions)

    # Make internal connections between child components
    connect(emissions.YGROSS, grosseconomy.YGROSS)

    # Export variables
    YGROSS = Variable(grosseconomy.YGROSS)
    E = Variable(emissions.E)

end