/datum/vampire_ability
	var/name = "Activated Ability"
	var/desc = "An activated ability usable by a vampire"

	var/channeled = FALSE		// Wait for the user to click on something after activation.
	var/channeling = FALSE

	var/blood_cost = 0
	var/cast_time = 0 SECONDS

	var/cooldown = 0 SECONDS
	var/last_activated = 0

	var/ui_icon_state
	var/element_type = /obj/abstract/mind_ui_element/hoverable/vampire_ability

	var/mindUI_id = "Vampire Left Panel"

	var/datum/role/vampire/vamp_role
	var/datum/vampire_mutation/vamp_mutation

/datum/vampire_ability/New(var/datum/role/vampire/V, var/datum/vampire_mutation/mut)
	vamp_role = V
	vamp_mutation = mut
	if(!vamp_role)
		stack_trace("A vampire ability was created, but no vampire role was set in New()!")
		qdel(src)
	if(!vamp_mutation)
		stack_trace("A vampire ability was created, but no vampire mutation was set in New()!")
		qdel(src)
	vamp_role.abilities.Add(src)
	GenerateUIElement()

/datum/vampire_ability/proc/GenerateUIElement()
	var/datum/mind_ui/vampire_left_panel/UI = vamp_role.antag.activeUIs[mindUI_id]
	var/obj/abstract/mind_ui_element/hoverable/vampire_ability/element = new element_type(null, UI)
	UI.elements += element
	element.name = name
	element.my_ability = src
	if(istype(UI))
		UI.SortElements()
	UI.SendToClient()
	UI.Display()
	return element

/datum/vampire_ability/proc/CheckBloodCost()
	if(!blood_cost)
		return TRUE
	var/amount_left = vamp_role.blood_vessel.get_reagent_amount(BLOOD)
	if(amount_left <= blood_cost)
		to_chat(vamp_role.antag.current, "<span class='warning'>You don't have enough blood!</span>")
		return FALSE
	return TRUE

/datum/vampire_ability/proc/Activate(atom/atom)
	if(!vamp_role)
		stack_trace("A vampire ability was activated without a vampire role set.")
		return
	if(last_activated + cooldown > world.time)
		to_chat(vamp_role.antag.current, "<span class='warning'>That ability is still on cooldown!</span>")
		return
	if(!CheckBloodCost())
		return
	if(channeled)
		if(!channeling)
			if(!CanChannel())
				return
			channeling = TRUE
			vamp_role.antag.DisplayUI("Vampire")
			vamp_role.antag.current.register_event(/event/uattack, src, .proc/Activate)
			return
		else
			channeling = FALSE
			vamp_role.antag.current.unregister_event(/event/uattack, src, .proc/Activate)
	if(!cast_time)
		if(vamp_role.UseBlood(blood_cost))
			last_activated = world.time
			Ability(vamp_role.antag.current, atom)
	else if(do_after(vamp_role.antag.current, vamp_role.antag.current, cast_time))
		if(vamp_role.UseBlood(blood_cost))
			last_activated = world.time
			Ability(vamp_role.antag.current, atom)
	vamp_role.antag.DisplayUI("Vampire")
	return

// Override this one!
/datum/vampire_ability/proc/Ability(var/mob/living/carbon/human/user, var/atom/target)
	return

// And this one!
/datum/vampire_ability/proc/IsToggled()
	return FALSE

// And this one too!
/datum/vampire_ability/proc/CanChannel()
	return TRUE

///////////////////////////////////////////

/datum/vampire_ability/web
	name = "Spin Web"
	desc = "Spin a web of congealed plasma to trap your enemies."
	ui_icon_state = "spider"
	cast_time = 2 SECONDS
	blood_cost = 5
	cooldown = 30 SECONDS

/datum/vampire_ability/web/Ability(var/mob/living/carbon/human/user)
	new /obj/effect/spider/stickyweb/vampire(get_turf(user))


///////////////////////////////////////////

/datum/vampire_ability/nausea
	name = "Relase Miasma"
	desc = "Release miasma to intoxicate your enemies."
	ui_icon_state = "nausea"
	blood_cost = 10
	cooldown = 10 SECONDS

/datum/vampire_ability/nausea/Ability(var/mob/living/carbon/human/user)
	for(var/turf/simulated/floor/T in dview(14, user.loc))
		new /obj/effect/miasma(T)

///////////////////////////////////////////

/datum/vampire_ability/blood_thief
	name = "Blood Thief"
	desc = "Steal blood from people you touch."
	ui_icon_state = "blood_thief"
	element_type = /obj/abstract/mind_ui_element/hoverable/vampire_ability/toggle

/datum/vampire_ability/blood_thief/Ability(var/mob/living/carbon/human/user)
	var/datum/vampire_mutation/blood_thief/BT = vamp_mutation
	BT.stealing = !BT.stealing
	to_chat(user, "<span class='notice'>You will [BT.stealing ? "now" : "no longer"] steal blood from people you touch.</span>")

/datum/vampire_ability/blood_thief/IsToggled()
	var/datum/vampire_mutation/blood_thief/BT = vamp_mutation
	return BT.stealing

//////

/datum/vampire_ability/blood_gift
	name = "Blood Thief"
	desc = "Gift medicine to people you touch."
	ui_icon_state = "blood_gift"
	element_type = /obj/abstract/mind_ui_element/hoverable/vampire_ability/toggle

/datum/vampire_ability/blood_gift/Ability(var/mob/living/carbon/human/user)
	var/datum/vampire_mutation/blood_thief/BT = vamp_mutation
	BT.gifting = !BT.gifting
	to_chat(user, "<span class='notice'>You will [BT.gifting ? "now" : "no longer"] gift medicine to people you touch.</span>")

/datum/vampire_ability/blood_gift/IsToggled()
	var/datum/vampire_mutation/blood_thief/BT = vamp_mutation
	return BT.gifting

///////////////////////////////////////////

/datum/vampire_ability/viral
	name = "Spawn Disease"
	desc = "Infect your blood with a new disease."
	ui_icon_state = "viral"
	cooldown = 5 SECONDS

/datum/vampire_ability/viral/Ability(var/mob/living/carbon/human/user)
	var/datum/disease2/disease/D = get_random_weighted_disease(WINFECTION)
	var/list/anti = list(
		ANTIGEN_BLOOD	= 1,
		ANTIGEN_COMMON	= 1,
		ANTIGEN_RARE	= 1,
		ANTIGEN_ALIEN	= 1,
		)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 1,
		EFFECT_DANGER_FLAVOR	= 1,
		EFFECT_DANGER_ANNOYING	= 1,
		EFFECT_DANGER_HINDRANCE	= 1,
		EFFECT_DANGER_HARMFUL	= 1,
		EFFECT_DANGER_DEADLY	= 1,
		)
	D.spread = SPREAD_BLOOD			// Only spreads through blood!
	D.origin = "Vampire Mutation"	// This is for admins only.... I think
	D.makerandom(list(60,100),list(60,100),anti,bad)
	user.infect_disease2(D,1, "Vampire Mutation")
	to_chat(user, "<span class='warning'>You feel diseased.</span>")

///////////////////////////////////////////

/datum/vampire_ability/wererat
	name = "Transform"
	desc = "Transform into a hideous rat."
	ui_icon_state = "wererat"

/datum/vampire_ability/wererat/Ability(var/mob/living/carbon/human/user)
	var/turf/T = get_turf(user)

	// Puff of smoke
	var/obj/effect/smoke/S = new(T)
	S.color = "#444444"

	// Transform the vampire
	var/mob/living/simple_animal/hostile/wererat/W = new(T)
	W.vampire_mob = user
	user.mind.transfer_to(W)
	user.forceMove(null)
	user.timestopped = TRUE

	// Have some decoys follow the player
	for(var/i = 1 to 3)
		var/mob/living/simple_animal/hostile/wererat/illusion/following/WFO = new(T,W)
		WFO.target = W
		WFO.MoveToTarget()

	// Create some decoy fleeing swarms
	for(var/i = 1 to 3)
		var/mob/living/simple_animal/hostile/wererat/illusion/fleeing/WFL = new(T,W)
		for(var/j = 1 to 3)
			var/mob/living/simple_animal/hostile/wererat/illusion/following/WFO = new(T,W)
			WFO.target = WFL
			WFO.MoveToTarget()

	// Create one "hostile decoy"
	var/mob/living/simple_animal/hostile/wererat/illusion/chasing/WC = new(T,W)
	for(var/j = 1 to 3)
		var/mob/living/simple_animal/hostile/wererat/illusion/following/WFO = new(T,W)
		WFO.target = WC
		WFO.MoveToTarget()

///////////////////////////////////////////

/datum/vampire_ability/speech
	name = "Mimic Speech"
	desc = "Replicate the voice of anyone you've heard."
	ui_icon_state = "raven"
	element_type = /obj/abstract/mind_ui_element/hoverable/vampire_ability/toggle

/datum/vampire_ability/speech/Ability(var/mob/living/carbon/human/user)
	var/datum/vampire_mutation/speech/VM = vamp_mutation
	if(VM.mimicing)
		VM.mimicing = ""
		to_chat(user, "<span class='notice'>You will now speak in your normal voice.</span>")
	else if(user.mind.heard_before.len == 0)
		to_chat(user, "<span class='warning'>You haven't heard anyone's voice yet!</span>")
	else
		var/mob/target = input(user, "Choose the target, from those whose voices you've heard before.", "Targeting") as null|anything in user.mind.heard_before
		if(!target)
			return
		VM.mimicing = target
		to_chat(user, "<span class='notice'>You will now mimic [target].</span>")


/datum/vampire_ability/speech/IsToggled()
	var/datum/vampire_mutation/speech/VM = vamp_mutation
	return VM.mimicing ? TRUE : FALSE


///////////////////////////////////////////

/datum/vampire_ability/burgeoning
	name = "Spread Vines"
	desc = "Spread vines to ensare your enemies."
	ui_icon_state = "vines"
	channeled = TRUE

/datum/vampire_ability/burgeoning/Ability(var/mob/living/carbon/human/user, var/atom/target)
	user.pointed(target)
