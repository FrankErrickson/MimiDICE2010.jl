using MimiDICE2010

m = MimiDICE2010.get_model_composite()

# Explore the model definition
md = m.md
md[:DICE2010][:Climate]

# Run the model
run(m)

# Explore the results
m.mi.comps_dict[:DICE2010].comps_dict[:Climate].comps_dict[:climatedynamics].variables.TATM

# getindex methods not yet implemented in Mimi:

# accessing variables and parameters that exist in DICE2010's namespace:
m[:DICE2010, :TATM]
m[:DICE2010, :DAMFRAC]
m[:DICE2010, :t2xco2]

# (potentially implement later) 
# accessing parameters/variables from lower subcomponents that haven't been exported to the top level:
m[:DICE2010][:Climate][:co2cycle, :MAT]
m[:DICE2010][:SocioEconomics][:emissions, :MIU]