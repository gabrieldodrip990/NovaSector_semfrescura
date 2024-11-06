/obj/item/circuitboard/machine/pacman/bluespace
	name = "GHOST-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman/bluespace

/obj/item/circuitboard/machine/pacman/bluespace/screwdriver_act(mob/living/user, obj/item/tool)
	return

/obj/item/circuitboard/machine/rad_collector
	name = "Radiation Collector"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	desc = "Comes with a small amount solder of arranged in the corner: \"If you can read this, you're too close.\""
	build_path = /obj/machinery/power/energy_accumulator/rad_collector
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/plasmarglass = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/servo = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/port_turbine
	name = "Portable Turbine Generator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	desc = "Comes with a small sticker on the corner: \"Warning: Not explosion-proof.\""
	build_path = /obj/machinery/power/port_turbine
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/plasmarglass = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/servo = 1)
	needs_anchored = FALSE
