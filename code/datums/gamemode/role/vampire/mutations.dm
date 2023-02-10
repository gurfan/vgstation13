/datum/role/vampire/proc/AddMutation(var/datum/vampire_mutation/mutation_type)
	if(initial(mutation_type.price) > mutation_points)
		return
	mutation_points -= initial(mutation_type.price)
	new mutation_type(src)


/datum/vampire_mutation
	var/name = "Vampire Mutation"
	var/desc = "Vampire mutations grant the vampire certain ability. Purchase them using mutation points"

	var/price = 0
	var/restricted = FALSE	 			// If set to TRUE, cannot be purchased like normal. Caste abilities are restricted.
	var/datum/role/vampire/vamp_role
	var/my_ability_type

/datum/vampire_mutation/New(var/datum/role/vampire/V)
	vamp_role = V
	if(!vamp_role)
		qdel(src)
	vamp_role.mutations.Add(src)
	OnPurchase()
	AddAbility()

/datum/vampire_mutation/proc/OnPurchase()


/datum/vampire_mutation/proc/AddAbility()
	if(!my_ability_type)
		return
	new my_ability_type(vamp_role)



/datum/vampire_mutation/regeneration
	name = "Regeneration"
	desc = "This powerful ability modifies a Vampire's physiology to metabolize blood at a greatly increased rate. Blood now metabolizes four times as quickly for the purpose of healing, and has a low likelihood per tick to revitalize one of a Vampire's severed or prosthetic limbs into its original form."
