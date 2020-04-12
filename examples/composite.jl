using MimiDICE2010

m = MimiDICE2010.get_model_composite()
# m = MimiDICE2010.get_model(variant = :COMPOSITE)  # returns the same thing as above

# Explore the model definition
md = m.md
md[:DICE2010][:Climate]

# Run the model
run(m)

# Explore the results
m.mi.comps_dict[:DICE2010].comps_dict[:Climate].comps_dict[:climatedynamics].variables.TATM