/spell/changeling
	name = "Changeling Spell"
	desc = "A template changeling spell."
	abbreviation = "CG"
	still_recharging_msg = "<span class='warning'>We are not ready to do that!</span>"

	school = "changeling"
	user_type = USER_TYPE_CHANGELING

	charge_type = Sp_RECHARGE
	charge_max = 1 SECOND
	invocation_type = SpI_NONE
	range = 0

	cooldown_min = 1 SECOND

	override_base = "changeling"
	hud_state = "wiz_disint"

	var/chemcost = 0
    var/max_genedamage = 100
    var/horrorallowed = 1
	var/required_dna = 0

/spell/changeling/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) 
		return FALSE
	var/datum/role/changeling/C = user.mind.GetRole(CHANGELING)
	if (!C)     //only changelings allowed
		return      
	if (C.chem_charges < chemcost)
		to_chat(C.antag.current, "<span class='warning'>We do not have enough chemicals stored! We require at least [chemcost] units of chemicals.</span>")
		return FALSE
	if(C.geneticdamage > max_genedamage)
		to_chat(C.antag.current, "<span class='warning'>Our genomes are still reassembling. We need time to recover first.</span>")
		return FALSE
	if(C.absorbed_dna.len < required_dna)
		to_chat(C.antag.current, "<span class='warning'>We require at least [required_dna] samples of compatible DNA.</span>")
		return FALSE
	if(!horrorallowed && ishorrorform(C.antag.current))
		to_chat(C.antag.current, "<span class='warning'>You are not permitted to taint our purity. You cannot do this as a Horror.</span>")
		return FALSE

/spell/changeling/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/C = user.mind.GetRole(CHANGELING)
	C.chem_charges -= chemcost


	