/spell/changeling/changespecies
	name = "Change Species"
	desc = "We take on the apperance of a species that we have absorbed."
	abbreviation = "CS"

    spell_flags = NEEDSHUMAN

	chemcost = 5
    required_dna = 1
	max_genedamage = 0
	allowhorror = 0

/spell/changeling/changespecies/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return 0

	if(changeling.absorbed_species.len < 2)
		to_chat(user, "<span class='warning'>We do not know of any other species genomes to use.</span>")
		return

	var/S = user.input("Select the target species: ", "Target Species", null) as null|anything in changeling.absorbed_species
	if(!S)
		return

	domutcheck(user, null)

	changeling.geneticdamage = 30

	user.visible_message("<span class='warning'>[user] transforms!</span>")

	H.set_species(S,1) //Until someone moves body colour into DNA, they're going to have to use the default.

	spawn(10)
		user.regenerate_icons()

	changeling_update_languages(changeling.absorbed_languages)
	feedback_add_details("changeling_powers","TR")

	..()

