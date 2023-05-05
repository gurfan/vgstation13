/datum/vampire_ability
	var/name = "Activated Ability"
	var/desc = "An activated ability usable by a vampire"

	var/channeled = FALSE		// Wait for the user to click on something after activation.
	var/channeling = FALSE

	var/blood_cost = 0
	var/cast_time = 0 SECONDS

	var/cooldown = 0 SECONDS
	var/last_activated = 0

	var/toggle = FALSE
	var/toggle_bg_off = "toggle-off"
	var/toggle_bg_on = "toggle-on"

	var/ui_icon_state
	var/element_type = /obj/abstract/mind_ui_element/hoverable/vampire_ability

	var/mindUI_id = "Vampire Left Panel"

	var/custom_do_after_checks = null
	var/custom_do_after_ticks = 10

	var/charging = FALSE

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
	if(charging)
		return
	if(!IsToggled() && last_activated + cooldown > world.time)
		to_chat(vamp_role.antag.current, "<span class='warning'>That ability is still on cooldown!</span>")
		return
	if(!CheckBloodCost())
		return
	if(!PreCastCheck(vamp_role.antag.current))
		return
	if(channeled && !IsToggled())
		if(!channeling)
			if(!CanChannel())
				return
			channeling = TRUE
			vamp_role.antag.DisplayUI("Vampire")
			vamp_role.antag.current.register_event(/event/uattack, src, .proc/Activate)
			return
		else
			if(!PostChannelCheck(vamp_role.antag.current, atom))
				return
			channeling = FALSE
			vamp_role.antag.current.unregister_event(/event/uattack, src, .proc/Activate)
			vamp_role.antag.DisplayUI("Vampire")
	PreCast(vamp_role.antag.current)

	charging = TRUE
	if(!cast_time || IsToggled() || do_after(vamp_role.antag.current, vamp_role.antag.current, cast_time, custom_do_after_ticks, custom_checks = custom_do_after_checks ? new /callback(src, custom_do_after_checks) : null))
		if(IsToggled() || vamp_role.UseBlood(blood_cost))		// This short-circuits. No blood is spent to un-toggle.
			last_activated = world.time
			Ability(vamp_role.antag.current, atom)
		vamp_role.antag.DisplayUI("Vampire")
	charging = FALSE


// Override this one!
/datum/vampire_ability/proc/Ability(var/mob/living/carbon/human/user, var/atom/target)
	return

// And this one!
/datum/vampire_ability/proc/IsToggled()
	return FALSE

// And this one too!
/datum/vampire_ability/proc/CanChannel()
	return TRUE

// Checks for some other thing after the user has channeled a spell and clicked.
/datum/vampire_ability/proc/PostChannelCheck(var/mob/living/user, var/atom/atom)
	return TRUE

// Check for things before attempting to cast/channel
/datum/vampire_ability/proc/PreCastCheck(var/mob/living/user)
	if(user.restrained())
		to_chat(user, "<span class='warning'>You can't do this while restrained!</span>")
		return FALSE
	return TRUE

// Ability behavior that fires right before the spell is CASTED (not channeled!)
/datum/vampire_ability/proc/PreCast(var/mob/living/user, var/atom/atom)
	return

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
	toggle = TRUE

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
	toggle = TRUE

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
	var/obj/effect/smoke/transparent/S = new(T)
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
	toggle = TRUE

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

/datum/vampire_ability/burgeoning/PostChannelCheck(var/mob/living/carbon/human/user, var/atom/target)
	var/turf/T = get_turf(target)
	if(T.density)
		to_chat(user, "<span class='warning'>Vines can't grow there!</span>")
		return FALSE
	return TRUE

/datum/vampire_ability/burgeoning/Ability(var/mob/living/carbon/human/user, var/atom/target)
	var/turf/T = get_turf(target)
	user.pointed(T)
//	var/obj/effect/plantsegment/vampire/P = new(T, null, T, TRUE)
//	P.spread_rapidly()
	new /obj/effect/plantsegment/vampire(T, null, null, TRUE)
	T.visible_message("<span class='danger'>Vines sprout from \the [T]!</span>")


///////////////////////////////////////////

/datum/vampire_ability/bloodsense
	name = "Blood Sense"
	desc = "Close your eyes to sense nearby entities."
	ui_icon_state = "sense"
	cooldown = 15 SECONDS
	toggle = TRUE
	toggle_bg_off = "charge-cover"

	var/sensing = FALSE

/datum/vampire_ability/bloodsense/Ability(var/mob/living/carbon/human/user)
	sensing = !sensing
	if(sensing)
		user.overlay_fullscreen("bloodsense", /obj/abstract/screen/fullscreen/bloodsense)
		user.update_fullscreen_alpha("bloodsense", 255, 5)

		user.client.images += bloodsense_mob
		user.client.images += bloodsense_human
		spawn(5)
			vamp_role.antag.current.update_perception()

	else
		user.clear_fullscreen("bloodsense", 5)
		user.client.images -= bloodsense_mob
		user.client.images -= bloodsense_human
		vamp_role.antag.current.update_perception()
		vamp_role.antag.current.handle_regular_hud_updates()



/datum/vampire_ability/bloodsense/IsToggled()
	return sensing


///////////////////////////////////////////

/datum/vampire_ability/visit
	name = "Ethereal Visit"
	desc = "Warp to a location for thirty seconds."
	ui_icon_state = "visit"
	cooldown = 30 SECONDS
	toggle = TRUE
	toggle_bg_off = "charge-cover"
	channeled = TRUE

	var/turf/return_turf
	var/poofed = FALSE

/datum/vampire_ability/visit/Ability(mob/living/carbon/human/user, atom/target)
	poofed = !poofed

	if(poofed)
		return_turf = get_turf(user)
		var/turf/T = get_turf(target)
		playsound(return_turf, 'sound/effects/cultjaunt_prepare.ogg', 75, 0, -3)
		return_turf.turf_animation('icons/effects/effects.dmi',"shadowstep")
		user.forceMove(T)
		var/obj/effect/smoke/transparent/S = new(T)
		S.color = "#444444"
		spawn(30 SECONDS)
			if(poofed)
				last_activated = world.time
				Ability(user)
	else
		var/turf/T = get_turf(user)
		playsound(T, 'sound/effects/cultjaunt_prepare.ogg', 75, 0, -3)
		T.turf_animation('icons/effects/effects.dmi',"shadowstep")
		user.forceMove(return_turf)
		var/obj/effect/smoke/transparent/S = new(return_turf)
		S.color = "#444444"
		return_turf = null


/datum/vampire_ability/visit/IsToggled()
	return poofed

///////////////////////////////////////////

/datum/vampire_ability/jaunt
	name = "Mist Form"
	desc = "Become incorporeal for a brief duration."
	ui_icon_state = "mist"
	cooldown = 30 SECONDS

/datum/vampire_ability/jaunt/Ability(mob/living/carbon/human/user, atom/target)
	ethereal_jaunt(user, 5 SECONDS, "mist", "demist", TRUE, FALSE, /datum/effect/system/steam_spread/black)


///////////////////////////////////////////

/datum/vampire_ability/pacify
	name = "Pacifying Gaze"
	desc = "Pacify a target for thirty seconds. You yourself will be pacified briefly."
	ui_icon_state = "pacify"
	cooldown = 3 SECONDS
	channeled = TRUE

/datum/vampire_ability/pacify/Ability(mob/living/carbon/human/user, atom/target)


	var/mob/living/M = target
	if(!isvampire(M))	// Vampires don't fear the gaze.
		to_chat(M, "<span class='danger big'>A terrifying gaze chills your body to the bone!</span>")
		M.vampire_pacified = TRUE
		spawn(30 SECONDS)
			M.vampire_pacified = FALSE
			to_chat(M, "<span class='warning'>You recover your composure.</span>")


	user.vampire_pacified = TRUE
	to_chat(user, "<span class='warning'>Your senses dull.</span>")
	spawn(5 SECONDS)
		user.vampire_pacified = FALSE



	playsound(target, 'sound/effects/stun_talisman.ogg', 45, 0, 0)

	var/obj/effect/pacifygaze/ray = new(get_turf(target))
	var/disty = target.y - user.y
	var/distx = target.x - user.x
	var/newangle
	if(!disty)
		if(distx >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(distx/disty)
		if(disty < 0)
			newangle += 180
		else if(distx < 0)
			newangle += 360
	var/matrix/mat = matrix()
	ray.transform = turn(mat,newangle)


/datum/vampire_ability/pacify/PostChannelCheck(mob/living/user, atom/atom)
	if(isliving(atom) && atom != user)
		return TRUE

/mob
	var/vampire_pacified= FALSE

///////////////////////////////////////////

/datum/vampire_ability/screech
	name = "Chiropteran Screech"
	desc = "Let out a piercing screech, loud enough to shatter windows and stun your enemies."
	ui_icon_state = "screech"
	cooldown = 10 SECONDS
	custom_do_after_checks = /datum/vampire_ability/screech/proc/check_interrupt
	cast_time = 1 SECONDS

	var/interrupted

/datum/vampire_ability/screech/Ability(mob/living/carbon/human/user)
	interrupted = FALSE

	var/list/in_view_7 = view(7, user)
	var/list/in_view_4 = view(4, user)

	playsound(user, Holiday == APRIL_FOOLS_DAY ? 'sound/effects/deletescream.ogg' : 'sound/effects/creepyshriek.ogg', 100, 1)
	for (var/mob/living/carbon/C in in_view_7)
		if(isvampire(C))
			continue
		if(C.is_deaf())
			continue
		to_chat(C, "<span class='danger'><font size='3'>You hear a ear piercing shriek and your senses dull!</font></span>")
		C.Knockdown(8)
		C.ear_deaf = 20
		C.stuttering = 20
		C.Stun(8)
		C.Jitter(150)

	// DEATH TO ALL GLASS
	for(var/obj/structure/window/W in in_view_4)
		W.shatter()
	for(var/obj/machinery/light/L in in_view_7)
		L.broken()
	for(var/obj/item/weapon/hatchet/tomahawk/T in in_view_7)
		T.shatter()
	for(var/obj/structure/mirror/M in in_view_7)
		M.shatter()
	for(var/obj/item/weapon/pocket_mirror/P in in_view_7)
		P.shatter()
	for(var/obj/item/weapon/virusdish/V in in_view_7)
		V.shatter()
	for(var/obj/item/weapon/reagent_containers/glass/beaker/B in in_view_7)
		B.health = 0
		B.try_break()
	for(var/obj/item/weapon/reagent_containers/food/drinks/D in in_view_7)
		D.create_broken_bottle()
	for(var/obj/machinery/computer/C in in_view_4)
		C.stat |= BROKEN
		C.update_icon()

/datum/vampire_ability/screech/PreCastCheck(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species && H.species.flags & SPECIES_NO_MOUTH)
			to_chat(H, "<span class='warning'>How are you going to screech without a mouth?</span>")
			return FALSE
	return TRUE


/datum/vampire_ability/screech/PreCast(var/mob/living/user)

	user.visible_message(user, "<span class='danger'>[user] takes a deep breath...</span>", "<span class='warning'>You suck in air to let out a piercing shriek...</span>")

	// TODO - FIND A BETTER WINDUP SOUND
	playsound(user, pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg'), 35, 1)
	user.register_event(/event/attacked_by, src, .proc/interrupt)
	user.register_event(/event/disarmed, src, .proc/interrupt)
	user.register_event(/event/slapped, src, .proc/interrupt)
	user.register_event(/event/shushed, src, .proc/interrupt)
	user.register_event(/event/hitby, src, .proc/interrupt)
	user.register_event(/event/unarmed_attack, src, .proc/interrupt)


/datum/vampire_ability/screech/proc/interrupt(mob/attacker, mob/attacked, obj/item/item)
	interrupted = TRUE

	if(ishuman(vamp_role.antag.current))
		var/mob/living/carbon/human/H = vamp_role.antag.current
		if(H.gender == FEMALE)
			playsound(H, pick(female_cough_sound), 100, 0)
		else
			playsound(H, pick(male_cough_sound), 100, 0)

	vamp_role.antag.current.visible_message("<span class='warning'>[vamp_role.antag.current] sputters!</span>", "<span class='warning'>...and get the wind knocked out of you!</span>")

	// There's a penalty for getting interrupted, but you won't be forced to wait the entire cooldown.
	last_activated = world.time - cooldown*(2/3)

	vamp_role.antag.current.unregister_event(/event/attacked_by, src, .proc/interrupt)
	vamp_role.antag.current.unregister_event(/event/disarmed, src, .proc/interrupt)
	vamp_role.antag.current.unregister_event(/event/slapped, src, .proc/interrupt)
	vamp_role.antag.current.unregister_event(/event/shushed, src, .proc/interrupt)
	vamp_role.antag.current.unregister_event(/event/hitby, src, .proc/interrupt)
	vamp_role.antag.current.unregister_event(/event/unarmed_attack, src, .proc/interrupt)

/datum/vampire_ability/screech/proc/check_interrupt(mob/user, use_user_turf, user_original_location, atom/target, target_original_location, needhand, obj/item/originally_held_item)
	if(interrupted)
		interrupted = FALSE
		return FALSE
	return TRUE

///////////////////////////////////////////

/datum/vampire_ability/pestilence
	name = "Pestilence"
	desc = "Release a swarm of locusts from your body."
	ui_icon_state = "pest"
	cooldown = 10 SECONDS

	var/swarms_to_spawn = 2
	var/list/swarms = list()

/datum/vampire_ability/pestilence/Ability(mob/living/carbon/human/user)
	var/turf/T = get_turf(user)
	for(var/i = 1 to swarms_to_spawn)
		swarms += new /mob/living/simple_animal/hostile/vampire_locusts(T, src)
	user.visible_message("<span class='danger'>A swarm of insects emerges from [user]!</span>", "<span class='warning'>The locusts emerge directly from your skin, tearing it apart!</span>")

	// Damage is split this way to ensure that the vampire won't get IB from using this. Bones may still break if the threshold is reached.
	user.apply_damage(10, BRUTE, LIMB_CHEST)
	user.apply_damage(10, BRUTE, LIMB_LEFT_ARM)
	user.apply_damage(10, BRUTE, LIMB_RIGHT_ARM)
	user.apply_damage(10, BRUTE, LIMB_GROIN)

	bloodmess_splatter(T)
	playsound(user, 'sound/effects/blobsplatspecial.ogg', 100, 0)

///////////////////////////////////////////

/datum/vampire_ability/bloodbolt
	name = "Blood Bolt"
	desc = "Launch a bolt of sanguine energy at your foes."
	ui_icon_state = "bolt"
	cooldown = 3 SECONDS
	channeled = TRUE
	blood_cost = 50

/datum/vampire_ability/bloodbolt/Ability(mob/living/carbon/human/user, atom/target)
	playsound(user, 'sound/weapons/hivehand_empty.ogg', 70, 1)
	var/obj/item/projectile/projectile = new /obj/item/projectile/bloodbolt(user.loc, user.dir)

	projectile.original = target
	projectile.starting = get_turf(user)
	projectile.target = get_turf(target)
	projectile.shot_from = user //fired from the user
	projectile.current = projectile.original
	projectile.yo = target.y - user.y
	projectile.xo = target.x - user.x
	spawn()
		projectile.OnFired()
		projectile.process()

/datum/vampire_ability/bloodbolt/PostChannelCheck(mob/living/user, atom/atom)
	if(get_turf(user) != get_turf(atom))
		return TRUE
	return FALSE

///////////////////////////////////////////

/datum/vampire_ability/lightning
	name = "Lightning"
	desc = "Sample Description."
	ui_icon_state = "bolt"
	cooldown = 3 SECONDS
	channeled = TRUE

/datum/vampire_ability/lightning/Ability(mob/living/carbon/human/user, atom/target)
	spawn()
		new /obj/effect/vampire_lightning(get_turf(user), get_turf(target))

