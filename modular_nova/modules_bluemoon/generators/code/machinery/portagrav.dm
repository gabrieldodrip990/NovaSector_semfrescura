#define PORTAGRAV_ICON_FILE 'modular_nova/modules_bluemoon/generators/icons/gravity_generator.dmi'

/obj/machinery/power/portagrav
	icon = PORTAGRAV_ICON_FILE
	range = 5
	max_range = 25
	var/mutable_appearance/portagrav_overlay
	var/flick_timerid

	COOLDOWN_DECLARE(portagrav_toggle)

/obj/machinery/power/portagrav/Initialize()
	. = ..()
	portagrav_overlay = mutable_appearance(
		PORTAGRAV_ICON_FILE,
		"",
		appearance_flags = RESET_COLOR,
	)
	SET_PLANE_EXPLICIT(portagrav_overlay, ABOVE_LIGHTING_PLANE, src)

/obj/machinery/power/portagrav/update_icon()
	. = ..()
	icon_state = panel_open ? "portagrav_fix" : "portagrav"

/obj/machinery/power/portagrav/update_overlays()
	. = ..()
	if(panel_open || (wire_mode && !surplus()) || (!wire_mode && !cell?.charge))
		. += "portagrav_fix_o"

/obj/machinery/power/portagrav/proc/finish_startup()
	cut_overlay(portagrav_overlay)
	portagrav_overlay.icon_state = "activated"
	add_overlay(portagrav_overlay)
	flick_timerid = null

/obj/machinery/power/portagrav/proc/finish_shutdown()
	cut_overlay(portagrav_overlay)
	flick_timerid = null

/obj/machinery/power/portagrav/toggle_on(mob/user)
	if(!COOLDOWN_FINISHED(src, portagrav_toggle))
		return
	. = ..()
	playsound(loc, 'sound/effects/empulse.ogg', 50, TRUE)
	COOLDOWN_START(src, portagrav_toggle, 2 SECONDS)

/obj/machinery/power/portagrav/turn_on(mob/user)
	. = ..()
	if(on)
		return
	if(flick_timerid)
		deltimer(flick_timerid)
	portagrav_overlay.icon_state = "startup"
	add_overlay(portagrav_overlay)
	flick_timerid = addtimer(CALLBACK(src, PROC_REF(finish_startup)), 15, TIMER_CLIENT_TIME | TIMER_DELETE_ME | TIMER_STOPPABLE)

/obj/machinery/power/portagrav/turn_off(mob/user)
	. = ..()
	if(on)
		return
	if(flick_timerid)
		deltimer(flick_timerid)
	portagrav_overlay.icon_state = "shutdown"
	flick_timerid = addtimer(CALLBACK(src, PROC_REF(finish_shutdown)), 9, TIMER_CLIENT_TIME | TIMER_DELETE_ME | TIMER_STOPPABLE)

/obj/machinery/power/portagrav/screwdriver_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_screwdriver(user, "portagrav_fix", base_icon_state, tool))
		return NONE
	if(on)
		turn_off(user)
	update_appearance(UPDATE_ICON)
	return ITEM_INTERACT_SUCCESS

#undef PORTAGRAV_ICON_FILE
