/mob/living/simple_animal/hostile/wererat
	name = "giant rat"
	desc = "It's a giant rat, frothing at the mouth."

	icon_state = "wererat"
	icon_living = "wererat"
	icon_dead = "gymrat-dead"

	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stomps on the"

	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	health = 60
	maxHealth = 60

	speak_emote = list("snarls")

	melee_damage_lower = 10
	melee_damage_upper = 20

	//mob_swap_flags = HUMAN
	size = SIZE_SMALL
	pass_flags = PASSTABLE
	see_in_dark = 7

	var/mob/living/carbon/human/vampire_mob
	var/list/illusions = list()

/mob/living/simple_animal/hostile/wererat/New()
	..()
	pixel_y = rand(-2, 12)
	pixel_x = rand(-8, 8)
	spawn(30 SECONDS)
		untransform()

/mob/living/simple_animal/hostile/wererat/Login()
	. = ..()
	client.CAN_MOVE_DIAGONALLY = TRUE
	DisplayUI("Vampire")


/mob/living/simple_animal/hostile/wererat/death()
	if(vampire_mob)
		untransform(TRUE)
		return
	..()

/mob/living/simple_animal/hostile/wererat/proc/untransform(var/stun = FALSE)
	if(!vampire_mob)
		return
	var/turf/T = get_turf(src)
	vampire_mob.forceMove(T)
	forceMove(null)
	vampire_mob.timestopped = FALSE
	if(mind)
		mind.transfer_to(vampire_mob)
	if(stun)
		vampire_mob.Stun(3)
		vampire_mob.Knockdown(3)
		vampire_mob.Jitter(20)
	visible_message("<span class='danger'>\The [src] shifts and contorts!</span>")
	var/obj/effect/smoke/transparent/S = new(T)
	S.color = "#444444"

	vampire_mob = null

	for(var/mob/living/simple_animal/hostile/wererat/illusion/I in illusions)
		spawn(rand(1,2))
			I.death()

	qdel(src)

/mob/living/simple_animal/hostile/wererat/Cross(atom/movable/mover, turf/target, height, air_group)
	return istype(target, type) ? TRUE : ..()


////////////////////////


// Base illusion type
/mob/living/simple_animal/hostile/wererat/illusion
	environment_smash_flags = 0
	// See get_unarmed_damage for damage
	health = 1
	maxHealth = 1
	var/mob/living/simple_animal/hostile/wererat/master = null

/mob/living/simple_animal/hostile/wererat/illusion/New(loc, var/mob/living/simple_animal/hostile/wererat/rat)
	..()
	if(istype(rat))
		master = rat
		rat.illusions += src
		spawn(rand(29 SECONDS, 31 SECONDS))
			death()

/mob/living/simple_animal/hostile/wererat/illusion/death()
	if(stat != DEAD)
		density = FALSE
		playsound(loc, get_sfx("disappear_sound"), 75, 0, -2)
		stat = DEAD
		animate(src, alpha = 0, time = 1 SECONDS)
		sleep(1 SECONDS)
		qdel(src)

/mob/living/simple_animal/hostile/wererat/illusion/Destroy()
	if(master)
		master.illusions -= src
	..()

// Flees immediately upon creation, and runs away from humans
/mob/living/simple_animal/hostile/wererat/illusion/fleeing
	retreat_distance = 11
	minimum_distance = 11

/mob/living/simple_animal/hostile/wererat/illusion/fleeing/New()
	..()
	walk_away(src,get_turf(src), retreat_distance, move_to_delay)

/mob/living/simple_animal/hostile/wererat/illusion/get_unarmed_damage()
	return 0.1


///

// Follows another mob relentlessly.

/mob/living/simple_animal/hostile/wererat/illusion/following/CanAttack(atom/the_target)
	return istype(the_target, /mob/living/simple_animal/hostile/wererat) && !istype(the_target, type)

/mob/living/simple_animal/hostile/wererat/illusion/following/AttackingTarget()
	if(target && istype(target, /mob/living/simple_animal/hostile/wererat/illusion/chasing))
		var/mob/living/simple_animal/hostile/S = target
		UnarmedAttack(S.target, Adjacent(target))		// If following a "chasing" wererat, bite the same target
	return

/mob/living/simple_animal/hostile/wererat/illusion/following/LoseTarget()
	return

/mob/living/simple_animal/hostile/wererat/illusion/following/LostTarget()
	return 				// never stop running!

/mob/living/simple_animal/hostile/wererat/illusion/following/FindTarget()
	return target		// Don't change targets.

///

// Same as parent subtype, but attacks humans.

/mob/living/simple_animal/hostile/wererat/illusion/chasing/New()
	..()
	GiveTarget(FindTarget())
	MoveToTarget()

/mob/living/simple_animal/hostile/wererat/illusion/chasing/AttackingTarget()
	if(ishuman(target))
		UnarmedAttack(target, Adjacent(target))

/mob/living/simple_animal/hostile/wererat/illusion/chasing/CanAttack(atom/the_target)
	return ishuman(the_target)

