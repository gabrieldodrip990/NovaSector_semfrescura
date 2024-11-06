GLOBAL_LIST_INIT(extra_wood_recipes, list(
	new/datum/stack_recipe("large painting frame", /obj/item/wallframe/painting/large, 4, time = 5 SECONDS, crafting_flags = NONE, category = CAT_ENTERTAINMENT),
	new/datum/stack_recipe("wooden cabinet", /obj/structure/closet/cabinet, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
))

/obj/item/stack/sheet/mineral/wood/get_main_recipes()
	. = ..()
	. += GLOB.extra_wood_recipes

GLOBAL_LIST_INIT(extra_metal_recipes, list(
	new/datum/stack_recipe("trash bin", /obj/structure/closet/crate/bin, 2, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_FURNITURE),
))

/obj/item/stack/sheet/iron/get_main_recipes()
	. = ..()
	. += GLOB.extra_metal_recipes
