
@defcomposite Damages begin

    # Add child components
    component(damages)
    component(neteconomy)
    component(welfare)

    # Resolve parameter namespace collisions
    YGROSS = Parameter(damages.YGROSS, neteconomy.YGROSS)

    # Make internal connections
    connect(neteconomy.DAMFRAC, damages.DAMFRAC)
    connect(welfare.CPC, neteconomy.CPC)

    # Export variables
    I = Variable(neteconomy.I)
    
end