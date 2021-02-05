#define RANDOMIZE_JUST_DONT 0 
#define RANDOMIZE_PER_CYCLE	1
#define RANDOMIZE_PER_FLOOR	2

/datum/artifact_effect/floors
	effecttype = "floors"
	valid_style_types = list(ARTIFACT_STYLE_WIZARD, ARTIFACT_STYLE_RELIQUARY, ARTIFACT_STYLE_PRECURSOR)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 2
	var/randomization		//0 - No randomization, 1 - Randomize floors per cycle, 2 - randomize floors per cycle
	var/chosen_floor = 1
	var/max_aura_range = 3
	var/max_pulse_range = 7

	var/list/available_floors = list(	
		/turf/simulated/floor,
		/turf/simulated/floor/carpet, 
		/turf/simulated/floor/arcade,
		/turf/simulated/floor/damaged,
		/turf/simulated/floor/grass,
		/turf/simulated/floor/engine/cult,
		/turf/simulated/floor/engine,
		/turf/simulated/floor/wood,
		/turf/simulated/floor/dark,
		/turf/simulated/floor/mineral/plastic,
		/turf/simulated/floor/mineral/phazon,
		/turf/simulated/floor/mineral/clockwork,
		/turf/simulated/floor/mineral/uranium,
		/turf/simulated/floor/mineral/diamond,
		/turf/simulated/floor/mineral/clown,
		/turf/simulated/floor/mineral/silver,
		/turf/simulated/floor/mineral/gold,
		/turf/simulated/floor/mineral/plasma,
		/turf/simulated/floor/glass,
		/turf/simulated/floor/glass/plasma
	)
	
/datum/artifact_effect/floors/New()
	..()
	if(effect == ARTIFACT_EFFECT_PULSE)
		effectrange = min(effectrange, 7)
	else if (effect == ARTIFACT_EFFECT_AURA)
		effectrange = min(effectrange, 3)
	chosen_floor = rand(1, available_floors.len)
	randomize_individual = rand(1, 2)

/datum/artifact_effect/floors/DoEffectAura()
	make_floors(10, effectrange))

/datum/artifact_effect/floors/DoEffectPulse()
	make_floors(25, effectrange))

/datum/artifact_effect/floors/proc/make_floors(var/range)
	if(holder)
		
		var/turf/floortype
		if(randomization == RANDOMIZE_JUST_DONT)
			floortype = available_floors[chosen_floor]			
		else
			floortype = pick(available_floors)

		for(var/turf/T in spiral_block(get_turf(holder), range))
			if(istype(T, /turf/space) || isfloor(T))

				if(randomization = RANDOMIZE_PER_FLOOR)
					floortype = pick(available_floors)
				else if (!floortype)
					floortype = available_floors[chosen_floor]

				T.ChangeTurf(floortype)
				sleep(2)


//Cycle through randomness
/datum/artifact_effect/floors/modify1(var/num)
	randomization += num
	if(randomization < 2)
		randomization = 0
	else if (randomization < 0)
		randomization = 2

//Increase or decrease range
/datum/artifact_effect/floors/modify2(var/num)
	effectrange += num
	if(effectrange < 0)
		effectrange = 0
	
//Cycle through available floors (does nothing if randomness is on)
/datum/artifact_effect/floors/modify3(var/num)
	chosen_floor += num
	if (chosen_floor <= 0)
		chosen_floor = available_floors.len	
	else if (chosen_floor > available_floors.len)
		chosen_floor = 1

#undef RANDOMIZE_JUST_DONT
#undef RANDOMIZE_PER_CYCLE
#undef RANDOMIZE_PER_FLOOR