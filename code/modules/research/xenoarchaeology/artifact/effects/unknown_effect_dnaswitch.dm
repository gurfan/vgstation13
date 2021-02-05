#define GIVE_RANDOM_MUTATION 0
#define GIVE_BAD_MUTATION 1
#define GIVE_GOOD_MUTATION 2

/datum/artifact_effect/dnaswitch
	effecttype = "dnaswitch"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_RELIQUARY, ARTIFACT_STYLE_WIZARD)
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 5
	var/severity
	var/changeUI = 0
	var/mutationtype = GIVE_RANDOM_MUTATION
	copy_for_battery = list("severity")

/datum/artifact_effect/dnaswitch/New()
	..()
	changeUI = rand(0,1)
	if(effect == ARTIFACT_EFFECT_AURA)
		severity = rand(5,30)
	else
		severity = rand(25,95)

/datum/artifact_effect/dnaswitch/DoEffectTouch(var/mob/toucher)
	var/weakness = GetAnomalySusceptibility(toucher)
	if(ishuman(toucher) && prob(weakness * 100))
		to_chat(toucher, pick("<span class='good'>You feel a little different.</span>",\
		"<span class='good'>You feel very strange.</span>",\
		"<span class='good'>Your stomach churns.</span>",\
		"<span class='good'>Your skin feels loose.</span>",\
		"<span class='good'>You feel a stabbing pain in your head.</span>",\
		"<span class='good'>You feel a tingling sensation in your chest.</span>",\
		"<span class='good'>Your entire body vibrates.</span>"))
		if(mutationtype == GIVE_GOOD_MUTATION)
			for(var/i = 1, i < min(severity/10, 10), i++)
				randmutg(toucher)
			return 1
		else if (mutationtype == GIVE_BAD_MUTATION)
			for(var/i = 1, i < min(severity/10, 10), i++)
				randmutb(toucher)
			return 1
		scramble(changeUI, toucher, weakness * severity)
	return 1

/datum/artifact_effect/dnaswitch/DoEffectAura()
	if(holder)
		for(var/mob/living/carbon/human/H in range(min(30, effectrange),get_turf(holder)))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(prob(30))
					to_chat(H, pick("<span class='good'>You feel a little different.</span>",\
					"<span class='good'>You feel very strange.</span>",\
					"<span class='good'>Your stomach churns.</span>",\
					"<span class='good'>Your skin feels loose.</span>",\
					"<span class='good'>You feel a stabbing pain in your head.</span>",\
					"<span class='good'>You feel a tingling sensation in your chest.</span>",\
					"<span class='good'>Your entire body vibrates.</span>"))
				if(mutationtype == GIVE_GOOD_MUTATION)
					randmutg(H)
					return 1
				else if (mutationtype == GIVE_BAD_MUTATION)
					randmutb(H)
					return 1
				scramble(changeUI, H, weakness * severity)

/datum/artifact_effect/dnaswitch/DoEffectPulse()
	if(holder)
		for(var/mob/living/carbon/human/H in range(200, get_turf(holder)))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(prob(75))
					to_chat(H, pick("<span class='good'>You feel a little different.</span>",\
					"<span class='good'>You feel very strange.</span>",\
					"<span class='good'>Your stomach churns.</span>",\
					"<span class='good'>Your skin feels loose.</span>",\
					"<span class='good'>You feel a stabbing pain in your head.</span>",\
					"<span class='good'>You feel a tingling sensation in your chest.</span>",\
					"<span class='good'>Your entire body vibrates.</span>"))
				if(mutationtype == GIVE_GOOD_MUTATION)
					for(var/i = 1, i < min(severity/10, 10), i++)
						randmutg(H)
					return 1
				else if (mutationtype == GIVE_BAD_MUTATION)
					for(var/i = 1, i < min(severity/10, 10), i++)
						randmutb(H)
					return 1
				scramble(changeUI, H, weakness * severity)


//Increase or decrease range
/datum/artifact_effect/dnaswitch/modify1(var/num)
	effectrange += num 
	if(effectrange < 0)
		effectrange = 0

//Increase or decrease severity
/datum/artifact_effect/dnaswitch/modify2(var/num)
	severity += num 
	if(severity < 0)
		severity = 0

//Switch between random/good/bad
/datum/artifact_effect/dnaswitch/modify3(var/num)
	mutationtype += num 
	if(mutationtype > GIVE_GOOD_MUTATION)
		mutationtype = GIVE_RANDOM_MUTATION
	else if(mutationtype < GIVE_RANDOM_MUTATION)
		mutationtype = GIVE_GOOD_MUTATION

#undef GIVE_RANDOM_MUTATION 
#undef GIVE_BAD_MUTATION 
#undef GIVE_GOOD_MUTATION 