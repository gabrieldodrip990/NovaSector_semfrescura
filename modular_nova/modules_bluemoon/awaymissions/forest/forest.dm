//Areas

/area/awaymission/forest
	name = "Forest"
	icon_state = "away2"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = "#FFFFCC"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambient_buzz = 'modular_nova/modules_bluemoon/awaymissions/forest/sound/ambience_forest.ogg'
	forced_ambience = TRUE
	ambient_buzz_vol = 25
	ambience_index = null
	ambientsounds = null
	sound_environment = SOUND_ENVIRONMENT_FOREST

/area/awaymission/forest/beach
	name = "Beach"
	icon_state = "away5"
	ambient_buzz = 'modular_nova/modules_bluemoon/awaymissions/forest/sound/ambience_beach.ogg'
	ambient_buzz_vol = 30

/area/awaymission/forest/glowing
	name = "Glowing Forest"
	icon_state = "away4"
	base_lighting_color = "#8fdef7"
	ambient_buzz = 'sound/ambience/aurora_caelus/aurora_caelus.ogg'
	ambient_buzz_vol = 15

/area/awaymission/forest/caves //entrance
	name = "Forest Cave"
	icon_state = "away"
	static_lighting = TRUE
	base_lighting_alpha = 0
	base_lighting_color = COLOR_WHITE
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/awaymission/forest/caves/deep
	name = "Forest Cave"
	icon_state = "away3"
	static_lighting = TRUE
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambient_buzz = 'modular_nova/modules_bluemoon/awaymissions/forest/sound/ambience_cave.ogg'
	ambient_buzz_vol = 45

//Turfs

/turf/open/misc/dirt/jungle/wasteland/noslow
	slowdown = 0

/turf/closed/mineral/indestructible //just an easy way to get the edged effect
	name = "mountain rock"
	desc = "Seems to be stronger than the other rocks in the area. You probably can't get through this."
	defer_change = 1
	icon_state = "rock_highchance"

/turf/closed/mineral/strong/attackby(obj/item/I, mob/user, params)
		return FALSE

/turf/closed/mineral/strong/gets_drilled(mob/user, give_exp = FALSE)
		return // see attackby

/turf/closed/mineral/strong/acid_melt()
	return

/turf/closed/mineral/strong/ex_act(severity, target)
	return FALSE

//Objects

/obj/structure/flora/tree/sif
	name = "glowing tree"
	desc = "It's a tree, except this one seems quite alien. It glows a deep blue."
	icon = 'modular_nova/modules_bluemoon/awaymissions/forest/icons/obj/sif.dmi'
	icon_state = "tree_sif"

/obj/structure/flora/tree/sif/Initialize(mapload)
	. = ..()
	set_light(5, 1, "#33ccff")
	icon_state = "tree_sif[rand(0, 3)]"
	update_appearance()
