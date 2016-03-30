
var/global/list/parasites = list() //all currently existing/living guardians

/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by its charge, ever vigilant."
	speak_emote = list("hisses")
	bubble_icon = "guardian"
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "magicOrange"
	icon_living = "magicOrange"
	icon_dead = "magicOrange"
	speed = 0
	a_intent = "harm"
	stop_automated_movement = 1
	floating = 1
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "punches"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5) //how much damage from each damage type we transfer to the owner
	environment_smash = 1
	melee_damage_lower = 15
	melee_damage_upper = 15
	butcher_results = list(/obj/item/weapon/ectoplasm = 1)
	AIStatus = AI_OFF
	var/reset = 0 //if the summoner has reset the guardian already
	var/cooldown = 0
	var/mob/living/summoner
	var/range = 10 //how far from the user the spirit can be
	var/toggle_button_type = /obj/screen/guardian/ToggleMode/Inactive //what sort of toggle button the hud uses
	var/datum/guardianname/namedatum = new/datum/guardianname()
	var/playstyle_string = "<span class='holoparasite'>You are a standard Guardian. You shouldn't exist!</span>"
	var/magic_fluff_string = "<span class='holoparasite'>You draw the Coder, symbolizing bugs and errors. This shouldn't happen! Submit a bug report!</span>"
	var/tech_fluff_string = "<span class='holoparasite'>BOOT SEQUENCE COMPLETE. ERROR MODULE LOADED. THIS SHOULDN'T HAPPEN. Submit a bug report!</span>"
	var/carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP SOME SORT OF HORRIFIC BUG BLAME THE CODERS CARP CARP CARP</span>"

/mob/living/simple_animal/hostile/guardian/New(loc, theme)
	parasites |= src
	setthemename(theme)

	//Special case holocarp, because #snowflake code
	if(theme == "carp")
		icon = 'icons/mob/animal.dmi'
		speak_emote = list("gnashes")
		desc = "A mysterious fish that stands by its charge, ever vigilant."

	..()

/mob/living/simple_animal/hostile/guardian/Destroy()
	parasites -= src
	return ..()

/mob/living/simple_animal/hostile/guardian/proc/setthemename(pickedtheme) //set the guardian's theme to something cool!
	if(!pickedtheme)
		pickedtheme = pick("magic", "tech", "carp")
	var/list/possible_names = list()
	switch(pickedtheme)
		if("magic")
			for(var/type in (subtypesof(/datum/guardianname/magic) - namedatum.type))
				possible_names += new type
		if("tech")
			for(var/type in (subtypesof(/datum/guardianname/tech) - namedatum.type))
				possible_names += new type
		if("carp")
			for(var/type in (subtypesof(/datum/guardianname/carp) - namedatum.type))
				possible_names += new type
	namedatum = pick(possible_names)
	updatetheme()

/mob/living/simple_animal/hostile/guardian/proc/updatetheme() //update the guardian's theme to whatever its datum is; proc for adminfuckery
	name = "[namedatum.prefixname] [namedatum.suffixcolour]"
	real_name = "[name]"
	icon_living = "[namedatum.parasiteicon]"
	icon_state = "[namedatum.parasiteicon]"
	icon_dead = "[namedatum.parasiteicon]"
	bubble_icon = "[namedatum.bubbleicon]"

/mob/living/simple_animal/hostile/guardian/Login() //if we have a mind, set its name to ours when it logs in
	..()
	if(mind)
		mind.name = "[real_name]"
	if(!summoner)
		src << "<span class='holoparasitebold'>For some reason, somehow, you have no summoner. Please report this bug immediately.</span>"
		return
	src << "<span class='holoparasite'>You are <font color=\"[namedatum.colour]\"><b>[real_name]</b></font>, bound to serve [summoner.real_name].</span>"
	src << "<span class='holoparasite'>You are capable of manifesting or recalling to your master with the buttons on your HUD. You will also find a button to communicate with them privately there.</span>"
	src << "<span class='holoparasite'>While personally invincible, you will die if [summoner.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself.</span>"
	src << playstyle_string

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	..()
	update_health_hud() //we need to update our health display to match our summoner and we can't practically give the summoner a hook to do it
	if(summoner)
		if(summoner.stat == DEAD)
			src << "<span class='danger'>Your summoner has died!</span>"
			visible_message("<span class='danger'><B>\The [src] dies along with its user!</B></span>")
			summoner.visible_message("<span class='danger'><B>[summoner]'s body is completely consumed by the strain of sustaining [src]!</B></span>")
			for(var/obj/item/W in summoner)
				if(!summoner.unEquip(W))
					qdel(W)
			summoner.dust()
			ghostize()
			qdel(src)
	else
		src << "<span class='danger'>Your summoner has died!</span>"
		visible_message("<span class='danger'><B>The [src] dies along with its user!</B></span>")
		ghostize()
		qdel(src)
	snapback()

/mob/living/simple_animal/hostile/guardian/Stat()
	..()
	if(statpanel("Status"))
		if(summoner)
			var/resulthealth
			if(iscarbon(summoner))
				resulthealth = round((abs(config.health_threshold_dead - summoner.health) / abs(config.health_threshold_dead - summoner.maxHealth)) * 100)
			else
				resulthealth = round((summoner.health / summoner.maxHealth) * 100, 0.5)
			stat(null, "Summoner Health: [resulthealth]%")
		if(cooldown >= world.time)
			stat(null, "Manifest/Recall Cooldown Remaining: [max(round((cooldown - world.time)*0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	. = ..()
	snapback()

/mob/living/simple_animal/hostile/guardian/proc/snapback()
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			src << "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!</span>"
			visible_message("<span class='danger'>\The [src] jumps back to its user.</span>")
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase/out, get_turf(src))
			forceMove(get_turf(summoner))
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase, get_turf(src))

/mob/living/simple_animal/hostile/guardian/canSuicide()
	return 0

/mob/living/simple_animal/hostile/guardian/AttackingTarget()
	if(src.loc == summoner)
		src << "<span class='danger'><B>You must be manifested to attack!</span></B>"
		return 0
	else
		..()
		return 1

/mob/living/simple_animal/hostile/guardian/death()
	..()
	summoner << "<span class='danger'><B>Your [name] died somehow!</span></B>"
	summoner.death()

/mob/living/simple_animal/hostile/guardian/update_health_hud()
	if(summoner && hud_used && hud_used.healths)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(config.health_threshold_dead - summoner.health) / abs(config.health_threshold_dead - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100, 0.5)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>"

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount) //The spirit is invincible, but passes on damage to the summoner
	. = ..()
	if(summoner)
		if(loc == summoner)
			return 0
		summoner.adjustBruteLoss(amount)
		if(amount)
			summoner << "<span class='danger'><B>Your [name] is under attack! You take damage!</span></B>"
			summoner.visible_message("<span class='danger'><B>Blood sprays from [summoner] as [src] takes damage!</B></span>")
		if(summoner.stat == UNCONSCIOUS)
			summoner << "<span class='danger'><B>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span></B>"
			summoner.adjustCloneLoss(amount*0.5) //dying hosts take 50% bonus damage as cloneloss
		update_health_hud()

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/gib()
	if(summoner)
		summoner << "<span class='danger'><B>Your [src] was blown up!</span></B>"
		summoner.gib()
	ghostize()
	qdel(src)

//MANIFEST, RECALL, TOGGLE MODE/LIGHT, SHOW TYPE

/mob/living/simple_animal/hostile/guardian/proc/Manifest()
	if(cooldown > world.time)
		return 0
	if(loc == summoner)
		forceMove(get_turf(summoner))
		PoolOrNew(/obj/effect/overlay/temp/guardian/phase, get_turf(src))
		cooldown = world.time + 10
		return 1
	return 0

/mob/living/simple_animal/hostile/guardian/proc/Recall()
	if(loc == summoner || cooldown > world.time)
		return 0
	PoolOrNew(/obj/effect/overlay/temp/guardian/phase/out, get_turf(src))

	forceMove(summoner)
	cooldown = world.time + 10
	return 1

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	src << "<span class='danger'><B>You don't have another mode!</span></B>"

/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(!luminosity)
		src << "<span class='notice'>You activate your light.</span>"
		SetLuminosity(3)
	else
		src << "<span class='notice'>You deactivate your light.</span>"
		SetLuminosity(0)

/mob/living/simple_animal/hostile/guardian/verb/ShowType()
	set name = "Check Guardian Type"
	set category = "Guardian"
	set desc = "Check what type you are."
	src << playstyle_string

//COMMUNICATION

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	if(summoner)
		var/input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")
		if(!input)
			return

		var/preliminary_message = "<span class='holoparasitebold'>[input]</span>" //apply basic color/bolding
		var/my_message = "<font color=\"[namedatum.colour]\"><b><i>[src]:</i></b></font> [preliminary_message]" //add source, color source with the guardian's color

		summoner << my_message
		var/list/guardians = summoner.hasparasites()
		for(var/para in guardians)
			para << my_message
		for(var/M in dead_mob_list)
			M << "<a href='?src=\ref[M];follow=\ref[src]'>(F)</a> [my_message]"

		log_say("[src.real_name]/[src.key] : [input]")

/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if(!input)
		return

	var/preliminary_message = "<span class='holoparasitebold'>[input]</span>" //apply basic color/bolding
	var/my_message = "<span class='holoparasitebold'><i>[src]:</i> [preliminary_message]</span>" //add source, color source with default grey...

	src << my_message
	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		G << "<font color=\"[G.namedatum.colour]\"><b><i>[src]:</i></b></font> [preliminary_message]" //but for guardians, use their color for the source instead
	for(var/M in dead_mob_list)
		M << "<a href='?src=\ref[M];follow=\ref[src]'>(F)</a> [my_message]"

	log_say("[src.real_name]/[src.key] : [text]")

//FORCE RECALL/RESET

/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (One Use)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. One use per Guardian."

	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/P = para
		if(P.reset)
			guardians -= P //clear out guardians that are already reset
	if(guardians.len)
		var/mob/living/simple_animal/hostile/guardian/G = input(src, "Pick the guardian you wish to reset", "Guardian Reset") as null|anything in guardians
		if(G)
			src << "<span class='holoparasite'>You attempt to reset <font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font>'s personality...</span>"
			var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [src.real_name]'s [G.real_name]?", "pAI", null, FALSE, 100)
			var/mob/dead/observer/new_stand = null
			if(candidates.len)
				new_stand = pick(candidates)
				G << "<span class='holoparasite'>Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance.</span>"
				src << "<span class='holoparasitebold'>Your <font color=\"[G.namedatum.colour]\">[G.real_name]</font> has been successfully reset.</span>"
				message_admins("[key_name_admin(new_stand)] has taken control of ([key_name_admin(G)])")
				G.ghostize(0)
				G.setthemename(G.namedatum.theme) //give it a new color, to show it's a new person
				G.key = new_stand.key
				G.reset = 1
				switch(G.namedatum.theme)
					if("tech")
						src << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> is now online!</span>"
					if("magic")
						src << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been summoned!</span>"
				guardians -= G
				if(!guardians.len)
					verbs -= /mob/living/proc/guardian_reset
			else
				src << "<span class='holoparasite'>There were no ghosts willing to take control of <font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font>. Looks like you're stuck with it for now.</span>"
		else
			src << "<span class='holoparasite'>You decide not to reset [guardians.len > 1 ? "any of your guardians":"your guardian"].</span>"
	else
		verbs -= /mob/living/proc/guardian_reset

////////parasite tracking/finding procs

/mob/living/proc/hasparasites() //returns a list of guardians the mob is a summoner for
	. = list()
	for(var/P in parasites)
		var/mob/living/simple_animal/hostile/guardian/G = P
		if(G.summoner == src)
			. |= G

/mob/living/simple_animal/hostile/guardian/proc/hasmatchingsummoner(mob/living/simple_animal/hostile/guardian/G) //returns 1 if the summoner matches the target's summoner
	return (istype(G) && G.summoner == summoner)


////////Creation

/obj/item/weapon/guardiancreator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "Guardian Spirit"
	var/use_message = "<span class='holoparasite'>You shuffle the deck...</span>"
	var/used_message = "<span class='holoparasite'>All the cards seem to be blank now.</span>"
	var/failure_message = "<span class='holoparasitebold'>..And draw a card! It's...blank? Maybe you should try again later.</span>"
	var/ling_failure = "<span class='holoparasitebold'>The deck refuses to respond to a souless creature such as you.</span>"
	var/list/possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive", "Lightning", "Protector", "Charger", "Assassin")
	var/random = TRUE
	var/allowmultiple = 0
	var/allowling = 0

/obj/item/weapon/guardiancreator/attack_self(mob/living/user)
	var/list/guardians = user.hasparasites()
	if(guardians.len && !allowmultiple)
		user << "You already have a [mob_name]!"
		return
	if(user.mind && user.mind.changeling && !allowling)
		user << "[ling_failure]"
		return
	if(used == TRUE)
		user << "[used_message]"
		return
	used = TRUE
	user << "[use_message]"
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_PAI, null, FALSE, 100)
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		spawn_guardian(user, theghost.key)
	else
		user << "[failure_message]"
		used = FALSE


/obj/item/weapon/guardiancreator/proc/spawn_guardian(var/mob/living/user, var/key)
	var/guardiantype = "Standard"
	if(random)
		guardiantype = pick(possible_guardians)
	else
		guardiantype = input(user, "Pick the type of [mob_name]", "[mob_name] Creation") as null|anything in possible_guardians
		if(!guardiantype)
			user << "[failure_message]" //they canceled? sure okay don't force them into it
			used = FALSE
			return
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch
	switch(guardiantype)

		if("Chaos")
			pickedtype = /mob/living/simple_animal/hostile/guardian/fire

		if("Standard")
			pickedtype = /mob/living/simple_animal/hostile/guardian/punch

		if("Ranged")
			pickedtype = /mob/living/simple_animal/hostile/guardian/ranged

		if("Support")
			pickedtype = /mob/living/simple_animal/hostile/guardian/healer

		if("Explosive")
			pickedtype = /mob/living/simple_animal/hostile/guardian/bomb

		if("Lightning")
			pickedtype = /mob/living/simple_animal/hostile/guardian/beam

		if("Protector")
			pickedtype = /mob/living/simple_animal/hostile/guardian/protector

		if("Charger")
			pickedtype = /mob/living/simple_animal/hostile/guardian/charger

		if("Assassin")
			pickedtype = /mob/living/simple_animal/hostile/guardian/assassin

	var/mob/living/simple_animal/hostile/guardian/G = new pickedtype(user, theme)
	G.summoner = user
	G.key = key
	G.faction |= user.faction
	switch(theme)
		if("tech")
			user << "[G.tech_fluff_string]"
			user << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> is now online!</span>"
		if("magic")
			user << "[G.magic_fluff_string]"
			user << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been summoned!</span>"
		if("carp")
			user << "[G.carp_fluff_string]"
			user << "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been caught!</span>"
	user.verbs += /mob/living/proc/guardian_comm
	user.verbs += /mob/living/proc/guardian_recall
	user.verbs += /mob/living/proc/guardian_reset

/obj/item/weapon/guardiancreator/choose
	random = FALSE

/obj/item/weapon/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains an alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Holoparasite"
	use_message = "<span class='holoparasite'>You start to power on the injector...</span>"
	used_message = "<span class='holoparasite'>The injector has already been used.</span>"
	failure_message = "<span class='holoparasitebold'>...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.</span>"
	ling_failure = "<span class='holoparasitebold'>The holoparasites recoil in horror. They want nothing to do with a creature like you.</span>"

/obj/item/weapon/guardiancreator/tech/choose/traitor
	possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive", "Lightning", "Assassin")

/obj/item/weapon/guardiancreator/tech/choose
	random = FALSE

/obj/item/weapon/paper/guardian
	name = "Holoparasite Guide"
	icon_state = "paper_words"
	info = {"<b>A list of Holoparasite Types</b><br>

 <br>
 <b>Chaos</b>: Ignites enemies on touch and causes them to hallucinate all nearby people as the parasite. Automatically extinguishes the user if they catch on fire.<br>
 <br>
 <b>Standard</b>: Devastating close combat attacks and high damage resist. Can smash through weak walls.<br>
 <br>
 <b>Ranged</b>: Has two modes. Ranged; which fires a constant stream of weak, armor-ignoring projectiles. Scout; Cannot attack, but can move through walls and is quite hard to see. Can lay surveillance snares, which alert it when crossed, in either mode.<br>
 <br>
 <b>Support</b>: Has two modes. Combat; Medium power attacks and damage resist. Healer; Heals instead of attack, but has low damage resist and slow movement. Can deploy a bluespace beacon and warp targets to it (including you) in either mode.<br>
 <br>
 <b>Explosive</b>: High damage resist and medium power attack that may explosively teleport targets. Can turn any object, including objects too large to pick up, into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered or after a delay.<br>
 <br>
 <b>Lightning</b>: Attacks apply lightning chains to targets. Has a lightning chain to the user. Lightning chains shock everything near them, doing constant damage.<br>
 <br>
 <b>Assassin</b>: Does low damage and takes full damage, but can enter stealth, causing its next attack to do massive damage and ignore armor. However, it becomes briefly unable to recall after attacking from stealth.<br
"}

/obj/item/weapon/paper/guardian/update_icon()
	return


/obj/item/weapon/storage/box/syndie_kit/guardian
	name = "holoparasite injector kit"

/obj/item/weapon/storage/box/syndie_kit/guardian/New()
	..()
	new /obj/item/weapon/guardiancreator/tech/choose/traitor(src)
	new /obj/item/weapon/paper/guardian(src)
	return

/obj/item/weapon/guardiancreator/carp
	name = "holocarp fishsticks"
	desc = "Using the power of Carp'sie, you can catch a carp from byond the veil of Carpthulu, and bind it to your fleshy flesh form."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "fishfingers"
	theme = "carp"
	mob_name = "Holocarp"
	use_message = "<span class='holoparasite'>You put the fishsticks in your mouth...</span>"
	used_message = "<span class='holoparasite'>Someone's already taken a bite out of these fishsticks! Ew.</span>"
	failure_message = "<span class='holoparasitebold'>You couldn't catch any carp spirits from the seas of Lake Carp. Maybe there are none, maybe you fucked up.</span>"
	ling_failure = "<span class='holoparasitebold'>Carp'sie is fine with changelings, so you shouldn't be seeing this message.</span>"
	allowmultiple = 1
	allowling = 1

/obj/item/weapon/guardiancreator/carp/choose
	random = TRUE
