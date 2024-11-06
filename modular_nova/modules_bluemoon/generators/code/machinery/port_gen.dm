/obj/machinery/power/port_gen
	var/use_custom_soundloop = FALSE
	var/custom_soundloop = /datum/looping_sound/generator

/obj/machinery/power/port_gen/Initialize(mapload)
	. = ..()
	if(use_custom_soundloop)
		soundloop = new custom_soundloop(src, active)

/obj/machinery/power/port_gen/pacman
	use_custom_soundloop = TRUE
	custom_soundloop = /datum/looping_sound/generator/portable

/obj/machinery/power/port_gen/pacman/bluespace
	name = "\improper G.H.O.S.T.-type portable generator"
	base_icon_state = "portgen2"
	icon_state = "portgen2_0"
	circuit = /obj/item/circuitboard/machine/pacman/bluespace
	sheet_path = /obj/item/stack/sheet/bluespace_crystal
	power_gen = 40000
	time_per_sheet = 1800
	use_custom_soundloop = FALSE
