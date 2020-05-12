m_flat = MimiDICE2010.get_model(variant=:DEFAULT)
m_comp = MimiDICE2010.get_model(variant=:COMPOSITE )

run(m_flat)
run(m_comp)

# check the main variables of interest
#   # Export the main variables of interest
#   YGROSS  = Variable(SocioEconomics.YGROSS)
#   E       = Variable(SocioEconomics.E)
#   MAT     = Variable(Climate.MAT)
#   TATM    = Variable(Climate.TATM)
#   TotSLR  = Variable(Climate.TotSLR)
#   DAMFRAC = Variable(Damages.DAMFRAC)
#   CPC     = Variable(Damages.CPC)
#   UTILITY = Variable(Damages.UTILITY)

Precision = 1.0e-11

@test maximum(m_comp[:DICE2010, :YGROSS] - m_flat[:emissions, :YGROSS]) ≈ 0. atol = Precision
@test maximum(m_comp[:DICE2010, :E] - m_flat[:emissions, :E]) ≈ 0. atol = Precision
@test maximum(m_comp[:DICE2010, :MAT] - m_flat[:radiativeforcing, :MAT]) ≈ 0. atol = Precision
@test maximum(m_comp[:DICE2010, :TATM] - m_flat[:damages, :TATM]) ≈ 0. atol = Precision
@test maximum(m_comp[:DICE2010, :TotSLR] - m_flat[:damages, :TotSLR]) ≈ 0. atol = Precision
@test maximum(m_comp[:DICE2010, :DAMFRAC] - m_flat[:neteconomy, :DAMFRAC]) ≈ 0. atol = Precision 
@test maximum(m_comp[:DICE2010, :CPC] - m_flat[:welfare, :CPC]) ≈ 0. atol = Precision
@test maximum(m_comp[:DICE2010, :UTILITY] - m_flat[:welfare, :UTILITY]) ≈ 0. atol = Precision

# Check all values in the namespace
for comp in keys(m_flat.md.namespace) # namespace of all components
    for datum in keys(m_flat.md[comp].namespace) # namespace of component
        # println("Checking component $comp datum $datum")
        if in(datum, keys(m_comp.md[:DICE2010].namespace))
            # println("Found in composite comp namespace")
            @test maximum(m_comp[:DICE2010, datum] - m_flat[comp, datum]) ≈ 0. atol = Precision
        else
            # println("Skipping, not found in composite comp namespace")
        end

    end
end
