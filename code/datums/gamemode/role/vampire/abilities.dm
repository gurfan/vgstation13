/datum/vampire_ability
	var/name = "Activated Ability"
	var/desc = "An activated ability usable by a vampire"

	var/blood_cost = 0
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
	UI.Display()

/datum/vampire_ability/proc/Activate()
	return
