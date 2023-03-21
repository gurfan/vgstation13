// Spinnerets web
/obj/effect/spider/stickyweb/vampire
	name = "plasma web"
	desc = "It's stringy and sticky"
	health = 10
	anchored = TRUE
	mouse_opacity = 1
	color = "#7e06ba"   // purple


/obj/effect/spider/stickyweb/vampire/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(70))
				qdel(src)
		if(3.0)
			if (prob(25))
				qdel(src)
	return

/obj/effect/spider/stickyweb/vampire/Cross(atom/movable/mover, turf/target, height, air_group)
	if(!ishuman(mover))
		return TRUE
	var/mob/living/M = mover
	if((M.HasVampireMutation(/datum/vampire_mutation/web) || isspider(M)))
		var/obj/effect/rooting_trap/vampireweb/web = new /obj/effect/rooting_trap/vampireweb(loc)
		web.stick_to(M)
		to_chat(M, "<span class='warning'>Resist or click the webs on your legs to free yourself!</span>")
		qdel(src)
	return TRUE

////

/obj/effect/rooting_trap/vampireweb
	name = "plasma web"
	desc = "A mess of sticky strings."
	mouse_opacity = 1
	color = "#7e06ba"   // purple
	icon_state = "stickyweb"
	resist_time = 5 SECONDS

/obj/effect/rooting_trap/vampireweb/stick_to(var/atom/A, var/side = null)
	var/turf/T = get_turf(A)
	playsound(T, 'sound/weapons/hivehand_empty.ogg', 75, 1)
	. = ..()
	if (.)
		visible_message("<span class='warning'>\The [src] wraps itself around [A], sticking them to \the [T]!</span>", "<span class='danger'>\The [src] wraps itself around your legs, sticking you to \the [T]!</span>")


/////////////////////////////



/obj/effect/miasma
	name = "cloud of miasma"
	icon_state = "mustard"
	anchored = TRUE
	alpha = 0
	var/active = FALSE

/obj/effect/miasma/New()
	..()
	processing_objects += src

	// :)
	spawn(6 SECONDS)								// Invisible for 6 seconds
		animate(src, alpha = 255, 4 SECONDS)		// Start to appear for 4 seconds
		spawn(4 SECONDS)
			active = TRUE
			spawn(30 SECONDS)						// Active for 30 seconds
				animate(src, alpha = 0, 3 SECONDS)	// Fade away for 3 seconds
				spawn(3 SECONDS)
					qdel(src)

/obj/effect/miasma/Destroy()
	processing_objects -= src
	..()

/obj/effect/miasma/process()
	if(!active)
		return
	for(var/mob/living/carbon/human/H in get_turf(src))
		ApplyOverlay(H)
		H.dizziness = max(500, H.dizziness + 10)
		H.stuttering += 5
		if(!H.lastpuke)
			to_chat(H, "<span class='danger'>A nauseating odor washes over you!</span>")
			H.vomit(0, 0, 4)


/obj/effect/miasma/Crossed(atom/movable/AM)
	if(isliving(AM) && active)
		ApplyOverlay(AM)


/obj/effect/miasma/proc/ApplyOverlay(var/mob/living/M)
	if(M.screens["miasma"])
		return
	var/obj/abstract/screen/fullscreen/miasma/mi = M.overlay_fullscreen("miasma", /obj/abstract/screen/fullscreen/miasma)
	mi.my_mob = M
	M.update_fullscreen_alpha("miasma", 255, 2 SECONDS)



/////////////////////////////

#define RESIDUE_FADE_TIME 10 SECONDS

/obj/effect/vampire_residue
	name = "vampire residue"
	anchored = TRUE
	var/strength = 3

/obj/effect/vampire_residue/New(var/loc, var/set_strength)
	..()
	strength = set_strength ? set_strength : 3
	icon_state = "residue[strength]"
	pulse()
	spawn(RESIDUE_FADE_TIME)
		fade_away()

/obj/effect/vampire_residue/proc/fade_away()
	strength -= 1
	if(!strength)
		animate(alpha = 0, time = 2 SECONDS)
		spawn(2 SECONDS)
			qdel(src)
	else
		icon_state = "residue[strength]"
		spawn(RESIDUE_FADE_TIME)
			fade_away()


/obj/effect/vampire_residue/proc/pulse()
	animate(src, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)//1
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)//2
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)//3
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)//4
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)//5
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)//9
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)//5
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)//4
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)//3
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)//2
	sleep(10 SECONDS)
	pulse()

#undef RESIDUE_FADE_TIME


/////////////////////////////

/obj/effect/plantsegment/vampire
	desc = "An extremely expansionistic species of vine. It has a metallic scent."


/obj/effect/plantsegment/vampire/New(var/newloc, var/datum/seed/newseed, var/turf/newepicenter, var/start_fully_mature = TRUE)
	if(!newseed)
		newseed = new /datum/seed/flower/rose
		newseed.potency = 200
		newseed.endurance = 200
		newseed.spread = 2
	..()
	spread_distance_limit = 5		// Only expand up to five tiles.
	spread_chance = 0				// Won't spread once they finish growing.

	if(!newepicenter)	 // We're the first vine. Play an animation.
		flick("vinespawn", src)
		sleep(5)

	update_icon()
	spawn(2)	// To ensure that the new segment is at its final location.
		update_neighbors()
		spread_rapidly()

/obj/effect/plantsegment/vampire/proc/spread_rapidly()
	if(!gcDestroyed && neighbors.len)
		spawn(rand(3,7))
			do_spread()
			update_neighbors()
			spread_rapidly()

/obj/effect/plantsegment/vampire/at_fringe()
	if(spread_distance_limit)
		if(get_dist(src,epicenter) >= round(spread_distance_limit*0.7))
			limited_growth = TRUE
			harvest = FALSE
			return 1
		else if(get_dist(src,epicenter) >= round(spread_distance_limit*0.9))
			limited_growth = TRUE
			harvest = FALSE
			return 2
	return 0
