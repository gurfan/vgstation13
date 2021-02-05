
/datum/artifact_effect/emp
	effecttype = "emp"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_WIZARD, ARTIFACT_STYLE_ANCIENT, ARTIFACT_STYLE_PRECURSOR, ARTIFACT_STYLE_RELIQUARY)
	effect = ARTIFACT_EFFECT_PULSE
	effect_type = 3

/datum/artifact_effect/emp/DoEffectPulse()
	if(holder)
		empulse(get_turf(holder), effectrange/2, effectrange)
		return 1

//Increase or decrease range
/datum/artifact_effect/emp/modify1(var/num)
	effectrange += num
	if(effectrange < 0)
		effectrange = 0