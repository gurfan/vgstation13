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
