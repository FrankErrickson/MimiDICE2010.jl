
@defcomposite SocioEconomics begin

    # Add child components
    Component(grosseconomy) 
    Component(emissions)

    # Make internal connections between child components
    connect(emissions.YGROSS, grosseconomy.YGROSS)

    # Export variables
    YGROSS = Variable(grosseconomy.YGROSS)
    E = Variable(emissions.E)

end