/datum/artifact_effect/floors
	effecttype = "floors"
	valid_style_types = list(ARTIFACT_STYLE_WIZARD, ARTIFACT_STYLE_RELIQUARY, ARTIFACT_STYLE_PRECURSOR)
	effect = list(ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 2
	var/randomize_cycle = 1 	//If set to 1 will randomize floors each "cycle", useless if randomize_individual is set to 1
	var/randomize_individual	//If set to 1 will randomize floors every time, makes randomize_cycle invalid if set to 1
	var/chosen_floor = 1

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
	chosen_floor = rand(1, available_floors.len)
	randomize_individual = rand(0, 1)

/datum/artifact_effect/floors/DoEffectAura()
	make_floors(min(3, effectrange))

/datum/artifact_effect/floors/DoEffectPulse()
	make_floors(min(7, effectrange))

/datum/artifact_effect/floors/proc/make_floors(var/range)
	if(holder)
		
		var/turf/floortype

		if(randomize_cycle)
			floortype = pick(available_floors)
		else
			floortype = available_floors[chosen_floor]

		for(var/turf/T in spiral_block(get_turf(holder), range))
			if(istype(T, /turf/space) || isfloor(T))

				if(randomize_individual)
					floortype = pick(available_floors)
				else if (!floortype)
					floortype = available_floors[chosen_floor]

				T.ChangeTurf(floortype)
				sleep(2)


//Set cycle randomness
/datum/artifact_effect/floors/modify1(var/num)
	randomize_cycle = num

//Set per-tile randomness
/datum/artifact_effect/floors/modify2(var/num)
	randomize_individual = num

//Increase or decrease range
/datum/artifact_effect/floors/modify3(var/num)
	effectrange += num

//Cycle through available floors (does nothing if randomness is on)
/datum/artifact_effect/floors/modify4(var/num)
	if (num) 
		chosen_floor += 1
	else 
		chosen_floor -= 1

	if (chosen_floor <= 0)
		chosen_floor = available_floors.len	
	else if (chosen_floor > available_floors.len)
		chosen_floor = 1