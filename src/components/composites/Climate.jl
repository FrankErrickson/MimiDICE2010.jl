
@defcomposite Climate begin

    # Add child components
    component(co2cycle)
    component(radiativeforcing)
    component(climatedynamics) 
    component(sealevelrise)

    # Resolve parameter name collisions
    fco22x = Parameter(radiativeforcing.fco22x, climatedynamics.fco22x)

    # Make internal connections
    connect(radiativeforcing.MAT, co2cycle.MAT)
    connect(radiativeforcing.MAT_final, co2cycle.MAT_final)
    connect(climatedynamics.FORC, radiativeforcing.FORC)
    connect(sealevelrise.TATM, climatedynamics.TATM)

    # Export variables
    TATM = Variable(climatedynamics.TATM)
    TotSLR = Variable(sealevelrise.TotSLR)

end