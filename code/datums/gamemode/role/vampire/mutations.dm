/datum/role/vampire/proc/AddMutation(var/mutation_type)
	if(initial(mutation_type.price) > mutation_points)
		return
	mutation_points -= initial(mutation_type.price)
	new mutation_type(src)



/datum/vampire_mutation
	name = "Vampire Mutation"
	desc = "Vampire mutations grant the vampire certain ability. Purchase them using mutation points"

	var/price = 0
	var/restricted = FALSE	 			// If set to TRUE, cannot be purchased like normal. Caste abilities are restricted.
	var/datum/role/vampire/my_role
	var/my_ability_type

/datum/vampire_mutation/proc/New(var/datum/role/vampire/vamp_role)
	if(!vamp_role)
		qdel(src)
	vamp_role.mutations.Add(src)
	OnPurchase()
	AddAbility()

/datum/vampire_mutation/proc/OnPurchase()


/datum/vampire_mutation/proc/AddAbility()
	if(!my_ability)
		return



/datum/vampire_ability
	name = "Activated Ability"
	desc = "An activated ability usable by a vampire"

	var/blood_cost = 0
	var/ui_icon_state
	var/ui_type = /obj/abstract/mind_ui_element/hoverable/vampire_ability

/datum/vampire_ability/New(var/datum/role/vampire/vamp_role)
	if(!vamp_role)
		stack_trace("A vampire ability was created, but no vampire role was set in New()!")
		qdel(src)
	vamp_role.abilities.Add(src)





/datum/vampire_ability/proc/Activate
