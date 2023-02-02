/datum/vampire_ability
	name = "Activated Ability"
	desc = "An activated ability usable by a vampire"

	var/blood_cost = 0
	var/ui_icon_state
	var/element_type = /obj/abstract/mind_ui_element/hoverable/vampire_ability
	var/ui_id = "Vampire Left Panel"

/datum/vampire_ability/New(var/datum/role/vampire/vamp_role)
	if(!vamp_role)
		stack_trace("A vampire ability was created, but no vampire role was set in New()!")
		qdel(src)
	vamp_role.abilities.Add(src)
	GenerateUIElement()

/datum/vampire_ability/proc/GenerateUIElement()
	var/datum/mind_ui/ui = vamp_role.antag.activeUIs[ui_id]
	var/obj/abstract/mind_ui_element/hoverable/vampire_ability/element = new element_type(null, ui)
	ui.elements += element
	element.my_ability = src
	ui.Display()

/datum/vampire_ability/proc/Activate()
	return
