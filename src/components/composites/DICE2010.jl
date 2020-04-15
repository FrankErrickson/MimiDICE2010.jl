# the structure is currently:
#                                                     DICE2010                        
#              ----------------------------------------------------------------------------------------------
#              |                                         |                                                   |
#       SocioEconomics                                Climate                                             Damages 
#       -------------                ---------------------------------------------                  -------------------
#      |             |               |            |                |              |                 |        |         |
# grosseconomy  emissions       co2cycle  radiativeforcing  climatedynamics  sealevelrise       damages  neteconomy  welfare       

@defcomposite DICE2010 begin

    # Add child components
    Component(SocioEconomics)
    Component(Climate)
    Component(Damages)

    # Resolve parameter namespace collisions
    l = Parameter(SocioEconomics.l, Damages.l)
    MIU = Parameter(SocioEconomics.MIU, Damages.MIU)

    # Make internal connections
    connect(Climate.E, SocioEconomics.E)
    connect(Damages.YGROSS, SocioEconomics.YGROSS)
    connect(Damages.TATM, Climate.TATM)
    connect(Damages.TotSLR, Climate.TotSLR)
    connect(SocioEconomics.I, Damages.I)

    # Export the main variables of interest
    YGROSS  = Variable(SocioEconomics.YGROSS)
    E       = Variable(SocioEconomics.E)
    MAT     = Variable(Climate.MAT)
    TATM    = Variable(Climate.TATM)
    TotSLR  = Variable(Climate.TotSLR)
    DAMFRAc = Variable(Damages.DAMFRAC)
    CPC     = Variable(Damages.CPC)
    UTILITY = Variable(Damages.UTILITY)
    

end