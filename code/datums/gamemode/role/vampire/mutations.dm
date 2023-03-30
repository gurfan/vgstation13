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
	new my_ability_type(vamp_role, src)

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


///////////////////////////////////////////

/datum/vampire_mutation/blood_thief
	name = "Blood Thief / Blood Gift"
	desc = "One should always be wary of contact with a Vampire, for their ability to secretly dig their teeth into our bodies is ever-present. With this Mutation, a Vampire is granted two abilities-- Blood Thief and Blood Gift. With Blood Thief enabled, a Vampire will secretly suck 10u of blood from anybody that they contact personally, or that personally contacts them-- such as with a hug, head-pat, or handshake. To mask the effect, targets are also injected with 5u of normal Dexalin. With Blood Gift enabled, the Vampire will grant a 'victim' a small quantity of bicaridine, kelotane, and anti-toxin. In all cases, any individual reagent will not be granted if they would lead to overdose. The cooldown is universal between the two, and either (or both) can be enabled at any time."
	my_ability_type = /datum/vampire_ability/blood_thief
	var/gifting = FALSE
	var/stealing = FALSE

/datum/vampire_mutation/blood_thief/AddAbility()
	..()
	new /datum/vampire_ability/blood_gift(vamp_role, src)

/datum/vampire_mutation/blood_thief/proc/Touched(var/mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(stealing)
		H.vessel.remove_reagent(BLOOD, 10)
		H.reagents.add_reagent(DEXALIN, 5)
		vamp_role.HandleBloodInjection(10)
	if(gifting)
		if(H.reagents.get_reagent_amount(BICARIDINE) < 10)
			H.reagents.add_reagent(BICARIDINE, 2)
		if(H.reagents.get_reagent_amount(KELOTANE) < 10	)
			H.reagents.add_reagent(KELOTANE, 2)
		if(H.reagents.get_reagent_amount(ANTI_TOXIN) < 10 )
			H.reagents.add_reagent(ANTI_TOXIN, 2)


///////////////////////////////////////////

/datum/vampire_mutation/viral
	name = "Viral"
	desc = " devious affliction of the Vampire's blood that makes it infectious with all manner of disease. When this Mutation is activated, the Vampire will gain a virus of random intensity, but which can only be transmitted through blood. They will be automatically immunized to this disease, and can spread it throughout the Crew as they wish."
	my_ability_type = /datum/vampire_ability/viral


///////////////////////////////////////////

/datum/vampire_mutation/wererat
	name = "Wererat Form"
	desc = "Some Vampires possess in them an ability to turn into truly hideous vermin. At will, they become a small rat, frothing at the mouth, which is capable of climbing under tables and people, and which moves considerably faster than a normal person. They are joined by a swarm of 15 other wererat illusions which block projectiles and confuse passers-by. This ability lasts a full thirty seconds or until cancelled manually, at which point the illusions will vanish. Keep in mind that- thankfully- these Wererats are not able to traverse vents, but they do have a fierce bite, and can rip open airlocks by touching them."
	my_ability_type = /datum/vampire_ability/wererat


///////////////////////////////////////////

/datum/vampire_mutation/speech
	name = "Raven Tongue"
	desc = "This Mutation gives a Vampire the uncanny ability to replicate sounds and voices, similarly to that of a horrible corvid. If it has heard a person's voice, it may speak with it-- though proper use of this ability may require additional implements, such as a fake ID or gas mask."
	my_ability_type = /datum/vampire_ability/speech
	var/mimicing = ""

///////////////////////////////////////////

/datum/vampire_mutation/chupacabra
	name = "Chupacabra"
	desc = "A Vampire with this mutation may hunt the blood of weak and vulnerable animals, draining them in the night for their own recreation and regeneration. They may latch onto the neck of any simple animal and drain it dry, leaving behind what we call Vampire Residue, an unremovable mote of dust which indicates Vampiric activity. This will rapidly heal all forms of damage, with strength depending on the size of the animal-- tiny like a mouse, small like a chicken, medium like a dog, or large like a goat or Russian."
	my_ability_type = /datum/vampire_ability/speech
	var/mimicing = ""


///////////////////////////////////////////

/datum/vampire_mutation/burgeoning
	name = "Burgeoning"
	desc = "This Vampire has grown a rather insidious relationship with plants, and may exploit their growth to hide its escape. When activated, the Vampire visibly points at a place within its view to quickly grow a large bushel of weeds, resembling kudzu. These weeds cannot spread. A 5x5 inner core blocks visibility, with an outer layer which does not. The vines have a good chance per tile to restrict people moving through them, though this includes the Vampire."
	my_ability_type = /datum/vampire_ability/burgeoning



///////////////////////////////////////////

/datum/vampire_mutation/reactive_blood
	name = "Reactive Blood"
	desc = "The blood of a Vampire with this Mutation is scared very easily. If a projectile comes within a tile's distance of the Vampire, including ones that it shot, it will immediately blink away to a random place between 14 and 28 tiles from its original location. It will leave behind 80u of its blood on the ground where they were hit. This is a drastic effect, and makes a Vampire's identity immediately obvious."
	var/last_blink = 0

/datum/vampire_mutation/reactive_blood/proc/AttemptBlink()
	if(!last_blink || world.time > last_blink + 10 SECONDS)
		var/mob/living/carbon/human/H = vamp_role.antag.current
		if(!isturf(H.loc))	// Don't attempt to blink when not on a turf.
			return
		if(H.timestopped)	// No.
			return

		if(vamp_role.UseBlood(80))
			last_blink = world.time
			var/list/floors = circlerangeturfs(H, 28) - circlerangeturfs(H, 14)
			for(var/turf/T in floors)
				if(!istype(T, /turf/simulated/floor))
					floors -= T

			var/turf/target_turf = pick(floors)
			if(!target_turf) // Oh well...
				return

			H.bloodwarp(target_turf)

///////////////////////////////////////////

/datum/vampire_mutation/ephemeral
	name = "Ephemeral"
	desc = "Vampires that are Ephemeral are easily identified by the fact that they do not show up in pictures, and cannot be seen by any entity using a camera-- including Silicons. This fact makes them immediately obvious in some circumstances, but also makes it radically more difficult for an Artificial Intelligence to track them."

/datum/vampire_mutation/ephemeral/OnPurchase()
	for(var/mob/living/silicon/S in player_list)
		S.HideVampire(vamp_role.antag.current)

/mob/living/silicon/proc/HideVampire(var/mob/living/vampire)
	if(!client)
		return
	var/image/blank = image(null)
	blank.override = TRUE
	blank.loc = vampire
	client.images += blank

///////////////////////////////////////////

/datum/vampire_mutation/cold
	name = "Deathly Cold"
	desc = "This Vampire's skin gains a terrible chill that cannot ever be quelled. They are almost completely immune to both the harsh effects of cold temperatures and the scalding temperatures of flames, surviving plasma-fire effortlessly. Unfortunately, this does not save them from the magical burning effects of starlight."

/datum/vampire_mutation/cold/OnPurchase()
	for(var/mob/living/silicon/S in player_list)
		S.HideVampire(vamp_role.antag.current)


///////////////////////////////////////////

/datum/vampire_mutation/bloodsense
	name = "Blood Sense"
	desc = "An ability which grants a Vampire the ability to sense blood-bearing entities through walls, like a form of thermal vision. However, this only functions while the Vampire is concentrating with their eyes closed, which makes them blind until cancelled. Beginning concentration is a free action, but after it is cancelled, the cooldown must be endured before concentration can begin again."
	my_ability_type = /datum/vampire_ability/bloodsense


