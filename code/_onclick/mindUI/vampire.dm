/datum/mind_ui/vampire
	uniqueID = "Vampire"
	sub_uis_to_spawn = list(
		/datum/mind_ui/vampire_right_panel,
		/datum/mind_ui/vampire_left_panel,
		)

/datum/mind_ui/vampire/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(isvampire(M))
		return TRUE
	return FALSE

////////////////////////////////////////////////////////////////////
//																  //
//						   RIGHT PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/vampire_right_panel
	uniqueID = "Vampire Right Panel"
	x = "RIGHT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/vampire_blood_gauge,
		/obj/abstract/mind_ui_element/vampire_blood_count,
		)
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/vampire_blood_gauge
	name = "Blood Vessel"
	icon = 'icons/ui/vampire/32x64.dmi'
	icon_state = "bloodcount_background"
	layer = MIND_UI_BACK
	offset_y = -117

/obj/abstract/mind_ui_element/vampire_blood_gauge/UpdateIcon()
	var/mob/living/carbon/human/H = GetUser()
	if(!istype(H))
		return
	overlays.len = 0

	var/blood_volume = H.vessel.get_reagent_amount(BLOOD)

	var/gauge_state = "bloodcount"
	if (round(blood_volume) <= 66)
		gauge_state = "bloodcount_crit"
	var/image/gauge = image('icons/ui/vampire/32x64.dmi', src, gauge_state)
	var/matrix/gauge_matrix = matrix()
	gauge_matrix.Scale(1,blood_volume/H.vessel.maximum_volume)
	gauge.transform = gauge_matrix
	gauge.layer = MIND_UI_BUTTON
	//gauge.pixel_x = -3
	gauge.pixel_y = round(-64 + 100 * (blood_volume/H.vessel.maximum_volume))
	overlays += gauge

	var/image/cover = image(icon, src, "bloodcount_cover")
	cover.layer = MIND_UI_FRONT
	overlays += cover

//------------------------------------------------------------

/obj/abstract/mind_ui_element/vampire_blood_count
	icon = 'icons/ui/vampire/32x64.dmi'
	icon_state = ""
	layer = MIND_UI_FRONT+1
	mouse_opacity = 0
	offset_y = -100

/obj/abstract/mind_ui_element/vampire_blood_count/UpdateIcon()
	var/mob/living/carbon/human/H = GetUser()
	if(!istype(H))
		return
	overlays.len = 0

	var/blood_volume = H.vessel.get_reagent_amount(BLOOD)

	overlays += String2Image("[blood_volume]")
	if(blood_volume >= 100)
		offset_x = 3
	else if(blood_volume >= 10)
		offset_x = 6
	else
		offset_x = 9
	UpdateUIScreenLoc()





////////////////////////////////////////////////////////////////////
//																  //
//						   LEFT PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/vampire_left_panel
	uniqueID = "Vampire Left Panel"
	x = "LEFT"
	element_types_to_spawn = list()
	display_with_parent = TRUE


/datum/mind_ui/vampire_left_panel/proc/SortElements()
	var/off_y = 120 - elements.len*20
	for(var/obj/abstract/mind_ui_element/E in elements)
		E.offset_y = off_y
		off_y = off_y + 40
		E.UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/vampire_ability
	name = "Vampire Ability"
	icon = 'icons/ui/vampire/32x32.dmi'
	icon_state = "background"

	offset_y = 120

	var/datum/vampire_ability/my_ability

/obj/abstract/mind_ui_element/hoverable/vampire_ability/Click()
	if(!my_ability)
		return
	var/mob/living/carbon/human/H = GetUser()
	if(!istype(H))
		return
	var/datum/role/vampire/V = isvampire(H)
	if(!istype(V))
		return
	my_ability.Activate()
