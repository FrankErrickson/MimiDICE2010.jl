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
    component(SocioEconomics)
    component(Climate)
    component(Damages)

    # Make internal connections
    connect(Climate.E, SocioEconomics.E)
    connect(Damages.YGROSS, SocioEconomics.YGROSS)
    connect(Damages.TATM, Climate.TATM)
    connect(Damages.TotSLR, Climate.TotSLR)
    connect(SocioEconomics.I, Damages.I)

end