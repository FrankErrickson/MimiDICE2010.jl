m_flat = MimiDICE2010.get_model(variant=:DEFAULT);
m_comp = MimiDICE2010.get_model(variant=:COMPOSITE );

run(m_flat)
run(m_comp)

# for now chck the main variables of interest
#   # Export the main variables of interest
#   YGROSS  = Variable(SocioEconomics.YGROSS)
#   E       = Variable(SocioEconomics.E)
#   MAT     = Variable(Climate.MAT)
#   TATM    = Variable(Climate.TATM)
#   TotSLR  = Variable(Climate.TotSLR)
#   DAMFRAc = Variable(Damages.DAMFRAC)
#   CPC     = Variable(Damages.CPC)
#   UTILITY = Variable(Damages.UTILITY)

