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

/datum/vampire_mutation/Destroy()
	OnRemoval()
	..()

/datum/vampire_mutation/proc/OnPurchase()		// Override this!
	return

/datum/vampire_mutation/proc/OnRemoval()		// And this!
	return

/datum/vampire_mutation/proc/AddAbility()
	if(!my_ability_type)
		return
	new my_ability_type(vamp_role)

//////////////// MUTATIONS  ////////////////

/datum/vampire_mutation/regeneration
	name = "Regeneration"
	desc = "This powerful ability modifies a Vampire's physiology to metabolize blood at a greatly increased rate. Blood now metabolizes four times as quickly for the purpose of healing, and has a low likelihood per tick to revitalize one of a Vampire's severed or prosthetic limbs into its original form."

///////////////////////////////////////////

/datum/vampire_mutation/dwarf
	name = "Nazusheb"
	desc = "An odd affliction of Vampiric flesh that transforms their form to become more industrious, short, and fond of alcohol-flavored blood. They are compact enough to climb on tables (though this will show as a normal 'Dwarf' mutation). In addition, the Vampiric curse affects them in a peculiar way-- they are immune to *all* oxygen damage, and cannot feel pain."

/datum/vampire_mutation/dwarf/OnPurchase()
	vamp_role.antag.current.update_transform()

/datum/vampire_mutation/dwarf/OnRemoval()
	vamp_role.antag.current.update_transform()

///////////////////////////////////////////

/datum/vampire_mutation/web
	name = "Spinnerets"
	desc = "Contained within this kind of Vampire's blood is the power to make webs composed of congealed plasma. These are invisible in low-light environments, and will trap anyone (besides anybody with Spinnerets) who steps into them until they resist out, requiring about 10 seconds of effort. However, spinning a web takes a full 2 seconds in of itself. Make note that while trapped subjects cannot move, they are able to use anything that's already in their hands, and should do their best to eliminate a Vampire threat nearby if possible."
	my_ability_type = /datum/vampire_ability/web

///////////////////////////////////////////

/datum/vampire_mutation/nausea
	name = "Nausea"
	desc = "This Vampire becomes an aspect of filth and disgust, and can release this foul odor to disorient and incapacitate unprepared victims. At will, they release a huge 14x14 wave of invisible miasma, which will come to effect and become a visible pinkish mist after 10 seconds. Miasma penetrates internals and will instantly make victims nauseous, meaning that they will need to throw up after a few moments. Visible, active miasma will finally fade after 30 seconds."
	my_ability_type = /datum/vampire_ability/nausea
