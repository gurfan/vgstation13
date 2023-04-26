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


////////////////////////

#define LOCUST_BRUTE_DAMAGE 	5
#define LOCUST_TOXIN_DAMAGE 	5
#define LOCUST_TOXIN_AMOUNT 	1
#define LOCUST_STOXIN_AMOUNT	3


/mob/living/simple_animal/hostile/vampire_locusts
	name = "locust swarm"
	desc = "A swarm of swollen, bloodthirsty locusts. Better start running."
	icon_state = "vamp_bees"
	icon_living = "vamp_bees"

	density = FALSE
	force_projectile_miss = TRUE
	minimum_distance = 0
	hostile_interest = 1
	//stat_attack = 1

	var/datum/vampire_ability/pestilence/vamp_ability = null

/mob/living/simple_animal/hostile/vampire_locusts/CanAttack(atom/the_target)
	. = ..()
	if(!.)
		return FALSE
	if(isliving(the_target))
		var/mob/living/M = the_target
		if(M.HasVampireMutation(/datum/vampire_mutation/pestilence))
			return FALSE

	if(vamp_ability)
		for(var/mob/living/simple_animal/hostile/vampire_locusts/VL in vamp_ability.swarms)
			if(VL != src && VL.target == the_target)			// Don't attack someone already being attacked by a partner swarm
				return FALSE

	return TRUE

// Start chasing IMMEDIATELY
/mob/living/simple_animal/hostile/vampire_locusts/New(loc, var/datum/vampire_ability/ability)
	..()
	vamp_ability = ability
	GiveTarget(FindTarget())
	MoveToTarget()


/mob/living/simple_animal/hostile/vampire_locusts/Life()
	..()
	if(!stat && prob(5))
		playsound(src, 'sound/effects/bees.ogg', 40, 1)
	animate(src, pixel_x = rand(-12,12) * PIXEL_MULTIPLIER, pixel_y = rand(-12,12) * PIXEL_MULTIPLIER, time = 10, easing = SINE_EASING)


/mob/living/simple_animal/hostile/vampire_locusts/FindTarget()
	. = ..()
	if(.)
		emote("me",,"swarms after [.]!")

// Similar to /mob/living/simple_animal/bee
/mob/living/simple_animal/hostile/vampire_locusts/AttackingTarget()
	var/mob/living/carbon/human/M = target
	var/sting_prob = 100
	if(istype(M))
		var/obj/item/clothing/worn_suit = M.wear_suit
		var/obj/item/clothing/worn_helmet = M.head
		if(worn_suit)
			var/bio_block = min(worn_suit.armor["bio"],70)
			var/perm_block = 70-70*worn_suit.permeability_coefficient
			sting_prob -= max(bio_block,perm_block) 	// Is your suit sealed? I can't get to 70% of your body.
		if(worn_helmet)
			var/bio_block = min(worn_helmet.armor["bio"],30)
			var/perm_block = 30-30*worn_helmet.permeability_coefficient
			sting_prob -= max(bio_block,perm_block) 	// Is your helmet sealed? I can't get to 30% of your body.

	var/brute_dam = LOCUST_BRUTE_DAMAGE
	var/toxin_dam = LOCUST_TOXIN_DAMAGE
	var/toxin_amt = LOCUST_TOXIN_AMOUNT
	var/stoxin_amt = LOCUST_STOXIN_AMOUNT

	if (!prob(sting_prob))
		M.visible_message("<span class='warning'>\The [src] are stinging \the [M] through their protection!</span>", "<span class='warning'>You have been stung by \the [src] through your protection!</span>")
		brute_dam = brute_dam/2
		toxin_dam = toxin_dam/2
		toxin_amt = toxin_amt/2
		stoxin_amt = stoxin_amt/2
	else
		M.visible_message("<span class='warning'>\The [src] are stinging \the [M]!</span>", "<span class='warning'>You have been stung by \the [src]!</span>")

	if(prob(30))
		M.audible_scream()

	M.apply_damage(brute_dam, BRUTE)
	M.apply_damage(toxin_dam, TOX)
	M.reagents.add_reagent(TOXIN, toxin_amt)
	M.reagents.add_reagent(STOXIN, stoxin_amt)
	M.flash_pain()

	playsound(src, 'sound/effects/bees.ogg', 60, 1)



/mob/living/simple_animal/hostile/vampire_locusts/proc/Flail(var/mob/living/M)
	M.visible_message("<span class='warning'>[M] flails helplessly at \the [src]!</span>", "<span class='danger'>You flail helplessly at \the [src]!</span>")
	playsound(M, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

/mob/living/simple_animal/hostile/vampire_locusts/bullet_act(obj/item/projectile/Proj)
	return

/mob/living/simple_animal/hostile/vampire_locusts/bite_act(mob/living/carbon/human/M)
	Flail(M)

/mob/living/simple_animal/hostile/vampire_locusts/kick_act(mob/living/carbon/human/M)
	Flail(M)

/mob/living/simple_animal/hostile/vampire_locusts/attackby(obj/item/O, mob/user, no_delay, originator)
	Flail(user)

/mob/living/simple_animal/hostile/vampire_locusts/attack_hand(mob/living/carbon/human/M)
	Flail(M)




#undef LOCUST_BRUTE_DAMAGE
#undef LOCUST_TOXIN_DAMAGE
#undef LOCUST_TOXIN_AMOUNT
#undef LOCUST_STONIX_AMOUNT
