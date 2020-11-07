
/obj/machinery/artifact_modifier
	name = "exotic particle modifier"
	desc = "A device that allows users to send signals to energy signatures. A sticker on the side warns about radioactivity."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "xenoarch_modder"
	anchored = 1
	density = 1
	idle_power_usage = 50
	active_power_usage = 750
	use_power = 1

	var/obj/machinery/artifact/cur_artifact
	var/datum/artifact_effect/isolated_effect
	var/obj/machinery/artifact_scanpad/owned_scanner = null
	var/obj/machinery/artifact_muncher/owned_muncher = null
	var/obj/effect/artifact_field/artifact_field
	light_color = "#E1C400"
	var/radiation_range = 4
	var/stored_charges = 0
	var/modify_parameter = 1		//set this to 1 or 0
	var/modify_target = 0		//set this to 1-8
	var/progress



/obj/machinery/artifact_modifier/New()
	..()
	reconnect_parts()

/obj/machinery/artifact_modifier/Destroy()
	isolated_effect = null
	cur_artifact = null
	if (owned_scanner)
		owned_scanner.modifier_console = null
		owned_scanner = null
	if(owned_muncher)
		owned_muncher.modifier_console = null
		owned_muncher = null
	if (artifact_field)
		qdel(artifact_field)
		artifact_field = null
	..()

/obj/machinery/artifact_modifier/proc/reconnect_parts()
	//connect to a nearby scanner pad
	owned_scanner = locate(/obj/machinery/artifact_scanpad) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/artifact_scanpad) in orange(1, src)
	if(owned_scanner)
		owned_scanner.modifier_console = src
		owned_scanner.desc = "Can modify the exotic particles of a large alien artifact that has been isolated in it."

	owned_muncher = locate(/obj/machinery/artifact_muncher) in get_step(src, dir)
	if(!owned_muncher)
		owned_muncher = locate(/obj/machinery/artifact_muncher) in orange(1, src)
	if(owned_muncher)
		owned_muncher.modifier_console = src
		owned_muncher.desc = "A machine that allows takes in small alien artifacts, harvesting any energy within them. The process destroys the artifact."


/obj/machinery/artifact_modifier/attack_hand(var/mob/user)

	if(stat & (NOPOWER|BROKEN))
		return

	//None of these machines are movable but it helps to have this if someone ever takes the time to make all the xenoarch machine buildable/moveable/whatever
	if(!owned_scanner || !owned_muncher)
		reconnect_parts()

	ui_interact(user)


/obj/machinery/artifact_modifier/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	
	var/list/data = list()


	if(owned_scanner)
		data["hasScanner"] = 1
	else 
		data["hasScanner"] = 0

	if(cur_artifact)
		data["hasArtifact"] = 1
		data["artifactID"] = cur_artifact.artifact_id
		if(cur_artifact.secondary_effect)
			data["hasSecondaryEffect"] = 1
		else 
			data["hasSecondaryEffect"] = 0
	else 
		data["hasArtifact"] = 0

	if(modify_target)
		data["isModifying"] = 1
	else 
		data["isModifying"] = 0

	if(isolated_effect)
		data["hasEffect"] = 1
	else 
		data["hasEffect"] = 0

	data["modifyParameter"] = modify_parameter
	data["storedCharges"] = stored_charges
	data["progress"] = progress

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "artifact_modifier.tmpl", "Artifact Modifier", 500,350)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(1)


 
/obj/machinery/artifact_modifier/Topic(href, href_list)
	if(..())
		return
	if(!owned_muncher || !owned_scanner)
		return

	if(href_list["switchType"])
		modify_parameter = text2num(href_list["switchType"])
		return TRUE

	if(href_list["modifyEffect"])
		var/number = text2num(href_list["modifyEffect"])
		if(stored_charges >= number)
			stored_charges = max(stored_charges - number, 0)
			modify_target = number
			say("Now modifying effect.")
			playsound(src, cur_artifact.activation_sound, 50, 0)
		else 
			say("Not enough charges stored.")
		update_icon()
		return TRUE

	if(href_list["releaseEffect"])
		isolated_effect = null
		return TRUE

	if(href_list["selectEffect"])
		var/input = text2num(href_list["selectEffect"])
		if(!cur_artifact)
			return FALSE
		if(input == 1)
			isolated_effect = cur_artifact.primary_effect
		if(input == 2)
			isolated_effect = cur_artifact.secondary_effect
		return TRUE

	if(href_list["findArtifact"])
		if(!owned_scanner)
			return FALSE
		for(var/obj/machinery/artifact/A in get_turf(owned_scanner))
			cur_artifact = A
			cur_artifact.anchored = 1
			cur_artifact.contained = 1
			cur_artifact.being_used = 1
			visible_message("<span class='notice'>[bicon(owned_scanner)] [owned_scanner] activates with a low hum.</span>")
			artifact_field = new /obj/effect/artifact_field(get_turf(owned_scanner))
			break
		if(!cur_artifact)
			visible_message("<b>[src]</b> states, \"Cannot initialize field, no artifact detected.\"")
			return FALSE
		return TRUE

	if(href_list["releaseArtifact"])
		if(artifact_field)	
			qdel(artifact_field)
			artifact_field = null
		if(cur_artifact)
			visible_message("<span class='notice'>[bicon(owned_scanner)] [owned_scanner] deactivates with a gentle shudder.</span>")
			cur_artifact.anchored = 0
			cur_artifact.being_used = 0
			cur_artifact.contained = 0
			cur_artifact = null
			isolated_effect = null
		return TRUE


/obj/machinery/artifact_modifier/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(modify_target)
		
		use_power = 2
		progress += rand(4,10)

		// Radiation
		var/turf/T = get_turf(src)
		for(var/mob/living/M in dview(radiation_range, T, INVISIBILITY_MAXIMUM))
			var/dist2mob = sqrt(get_dist_squared(T, get_turf(M)))
			var/rads = 40 / max(1,dist2mob) //Distance/rads: 1 = 40, 2 = 20, 3 = 13, 4 = 10
			M.apply_radiation(round(rads),RAD_EXTERNAL)

		if(progress >= 100)
			progress = 0
			isolated_effect.modify_effect(modify_target, modify_parameter)
			modify_target = 0
			visible_message("<b>[src]</b> beeps.")

	else
		use_power = 1

	update_icon()

/obj/machinery/artifact_modifier/power_change()
	..()
	update_icon()

/obj/machinery/artifact_modifier/update_icon()
	overlays.len = 0
	set_light(0)
	icon_state = "xenoarch_modder"

	if(stat & (NOPOWER|BROKEN))
		icon_state = "xenoarch_modder_off"
		return

	if (modify_target != 0)
		set_light(2,2)
		if(modify_parameter)
			icon_state = "xenoarch_modder_positive"
		else
			icon_state = "xenoarch_modder_negative"
		
	if (owned_scanner)
		owned_scanner.update_icon()


/obj/machinery/artifact_muncher
	name = "exotic material decomposer"
	desc = "A machine that takes in small alien artifacts, harvesting any energy within them. The process destroys the artifact. It's useless without a nearby artifact modifier."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "xenoarch_muncher"
	anchored = 1
	density = 1
	idle_power_usage = 50
	active_power_usage = 750
	use_power = 1

	var/obj/machinery/artifact_modifier/modifier_console = null
	var/list/accepted_items = list(

		//Magic urns
		/obj/item/weapon/reagent_containers/glass/replenishing = 5,
		/obj/item/weapon/reagent_containers/glass/xenoviral = 2,

		//Generic wierd items
		/obj/item/weapon/archaeological_find = 1,

		//Valuable weapons
		/obj/item/weapon/kitchen/utensil/knife/large/ritual = 2,
		/obj/item/weapon/claymore = 5,
		/obj/item/weapon/katana = 5,
		/obj/item/weapon/nullrod/sword/chaos = 5,
		/obj/item/device/instrument/guitar/magical = 5,

		//Guns 
		/obj/item/weapon/gun/energy/laser/alien = 3,	
		/obj/item/weapon/gun/energy/laser/captain/alien = 5,
		/obj/item/weapon/gun/energy/bison/alien = 10,
		/obj/item/weapon/gun/projectile/xenoarch = 3,
		/obj/item/weapon/gun/projectile/roulette_revolver = 3,

		//Cult clothing
		/obj/item/weapon/melee/cultblade/nocult = 1,
		/obj/item/clothing/head/culthood = 1,
		/obj/item/clothing/suit/cultrobes = 1,
		/obj/item/clothing/head/culthood/old = 1,
		/obj/item/clothing/suit/cultrobes/old = 1,
		/obj/item/clothing/head/magus = 1,
		/obj/item/clothing/suit/magusred = 1,
		/obj/item/clothing/head/helmet/space/cult = 3,
		/obj/item/clothing/suit/space/cult = 3,
		/obj/item/clothing/head/helmet/space/legacy_cult = 5,
		/obj/item/clothing/suit/space/legacy_cult = 5,

		//Soulstones
		/obj/item/soulstone = 10,

		//Fossils
		/obj/item/weapon/fossil/ = 1,

		//Magic masks
		/obj/item/clothing/mask/morphing = 10,
		/obj/item/clothing/mask/happy = 5,

		//Magic dice
		/obj/item/weapon/dice/d20/cursed = 10,

		//Red ribbon arm
		/obj/item/red_ribbon_arm = 5,

	)

/obj/machinery/artifact_muncher/attackby(var/obj/item/I, var/mob/user)
	if (!modifier_console)
		to_chat(user, "<span class='warning'>The artifact decomposer isn't hooked up to a modifier.</span>")
		return
	if(!locate(I) in accepted_items)
		to_chat(user, "<span class='warning'>The artifact decomposer refuses to process that item!</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 75, 0)
		return
	else 
		user.drop_item(I)
		to_chat(user, "<span class='notice'>You add the [I.name] to the artifact decomposer.</span>")
		playsound(src, 'sound/machines/blender.ogg', 50, 1)
		modifier_console.stored_charges += accepted_items[I.type]
		qdel(I)


/obj/machinery/artifact_muncher/Destroy()
	modifier_console = null
	..()


