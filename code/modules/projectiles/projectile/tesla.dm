#define MAX_LIGHTNING_PER_PULSE 3
#define LIGHTNING_RANGE 3
#define PULSE_SHOCK_CHANCE 50
#define MIN_LIGHTNING_DAMAGE 15

/obj/item/projectile/teslaball
	name = "tesla ball"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "gravitywell"
	damage = 0
	fire_sound = 'sound/weapons/wave.ogg'
	phase_type = PROJREACT_WINDOWS|PROJREACT_OBJS|PROJREACT_MOBS
	penetration = -1
	kill_count = 20
	projectile_speed = 3

	var/charge = 0
	var/list/shocked_people = list()    //each person only gets shocked once


/obj/item/projectile/teslaball/New()
	..()
	spawn(1 SECONDS)  
		Pulse()

/obj/item/projectile/teslaball/to_bump(atom/A)
	..()
	Zap(A, FALSE)


/obj/item/projectile/teslaball/proc/Pulse() 
	var/fired_bolts = 0
	var/list/victims = list()
	var/list/possible_turfs = list()

	for(var/mob/living/M in view(LIGHTNING_RANGE,src))
		victims += M

	while(victims.len > 0)
		var/mob/living/victim = pick(victims)
		if(prob(PULSE_SHOCK_CHANCE))
			Zap(victim)
			fired_bolts++
		victims -= victim
		sleep(0.1 SECONDS)
		if(fired_bolts >= MAX_LIGHTNING_PER_PULSE)  //we're done here
			sleep(0.5 SECONDS) 
			Pulse()
			return
	
	//we ran out of people to shock, just electrify random turfs now
	for(var/turf/T in view(LIGHTNING_RANGE,src))
		possible_turfs += T
	while(fired_bolts < MAX_LIGHTNING_PER_PULSE && possible_turfs.len > 0)   
		Zap(pick(possible_turfs))
		fired_bolts++
		sleep(0.1 SECONDS)

	sleep(0.5 SECONDS)
	Pulse()
	return
			

/obj/item/projectile/teslaball/proc/ShootLightning(var/atom/target) 
	var/turf/U = get_turf(target)
	var/turf/T = get_turf(src)
	var/obj/item/projectile/beam/lightning/L = new /obj/item/projectile/beam/lightning(src)

	playsound(src, 'sound/effects/eleczap.ogg', 75, 1)
	L.tang = adjustAngle(get_angle(U,T))
	L.icon = midicon
	L.icon_state = "[L.tang]"
	L.firer = src
	L.def_zone = LIMB_CHEST
	L.original = target
	L.current = U
	L.starting = U
	L.yo = U.y - T.y
	L.xo = U.x - T.x
	L.stun = 0 //stun handled by electrocute_act
	L.eyeblur = 10
	L.stutter = 10
	spawn L.process()

/obj/item/projectile/teslaball/proc/CalculateDamage() 
	var/strength = charge / (5 * MEGAWATT)		 
	if(strength < MIN_LIGHTNING_DAMAGE)
		strength = MIN_LIGHTNING_DAMAGE
	return strength

/obj/item/projectile/teslaball/proc/Zap(var/atom/target, var/bolt = TRUE)
	var/energy_force = CalculateDamage()
	var/knockdown_time = min(energy_force / 2, 15)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.electrocute_act(shock_damage = energy_force, source = src, incapacitation_duration = energy_force SECONDS, def_zone = LIMB_CHEST)
	else if(isliving(target))
		var/mob/living/M = target
		M.electrocute_act(shock_damage = energy_force, source = src, incapacitation_duration = energy_force SECONDS)
	if(bolt)
		ShootLightning(target)

