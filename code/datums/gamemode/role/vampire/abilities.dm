/datum/vampire_ability
	var/name = "Activated Ability"
	var/desc = "An activated ability usable by a vampire"

	var/blood_cost = 0
	var/cast_time = 0 SECONDS
	var/ui_icon_state
	var/element_type = /obj/abstract/mind_ui_element/hoverable/vampire_ability

	var/mindUI_id = "Vampire Left Panel"

	var/datum/role/vampire/vamp_role

/datum/vampire_ability/New(var/datum/role/vampire/V)
	vamp_role = V
	if(!vamp_role)
		stack_trace("A vampire ability was created, but no vampire role was set in New()!")
		qdel(src)
	vamp_role.abilities.Add(src)
	GenerateUIElement()

/datum/vampire_ability/proc/GenerateUIElement()
	var/datum/mind_ui/vampire_left_panel/UI = vamp_role.antag.activeUIs[mindUI_id]
	var/obj/abstract/mind_ui_element/hoverable/vampire_ability/element = new element_type(null, UI)
	UI.elements += element
	element.my_ability = src
	if(istype(UI))
		UI.SortElements()
	UI.SendToClient()
	UI.Display()

/datum/vampire_ability/proc/CheckBloodCost()
	if(!blood_cost)
		return TRUE
	var/amount_left = vamp_role.blood_vessel.get_reagent_amount(BLOOD)
	if(amount_left <= blood_cost)
		to_chat(vamp_role.antag.current, "<span class='warning'>You don't have enough blood!</span>")
		return FALSE
	return TRUE

/datum/vampire_ability/proc/Activate()
	if(!vamp_role)
		stack_trace("A vampire ability was activated without a vampire role set.")
		return
	if(!CheckBloodCost())
		return

	if(!cast_time)
		if(vamp_role.UseBlood(blood_cost))
			Ability()
	else if(do_after(vamp_role.antag.current, vamp_role.antag.current, cast_time))
		if(vamp_role.UseBlood(blood_cost))
			Ability()


// Override this one!
/datum/vampire_ability/proc/Ability()
	return

///////////////////////////////////////////

/datum/vampire_ability/web
	name = "Spin Web"
	desc = "Spin a web of congealed plasma to trap your enemies."
	ui_icon_state = "spider"
	cast_time = 2 SECONDS
	blood_cost = 5

/datum/vampire_ability/web/Ability()
	new /obj/effect/spider/stickyweb/vampire(get_turf(vamp_role.antag.current))

