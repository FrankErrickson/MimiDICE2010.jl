
@defcomposite Damages begin

    # Add child components
    Component(damages)
    Component(neteconomy)
    Component(welfare)

    # Resolve parameter namespace collisions
    YGROSS = Parameter(damages.YGROSS, neteconomy.YGROSS)
    l = Parameter(neteconomy.l, welfare.l)

    # Make internal connections
    connect(neteconomy.DAMFRAC, damages.DAMFRAC)
    connect(welfare.CPC, neteconomy.CPC)

    # Export variables
    I       = Variable(neteconomy.I)
    DAMFRAC = Variable(damages.DAMFRAC)
    CPC     = Variable(welfare.CPC)
    UTILITY = Variable(welfare.UTILITY)
    
end