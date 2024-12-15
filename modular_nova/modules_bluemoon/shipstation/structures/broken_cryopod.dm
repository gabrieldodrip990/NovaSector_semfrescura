/// The coolest hiding spot ever.
/obj/structure/closet/crate/freezer/cryo
	name = "broken cryogenic freezer"
	desc = "This broken cryo-pod was once a safe place for personnel to get some rest, but now it's only useful for keeping food cold."
	icon = 'modular_nova/modules/cryosleep/icons/cryogenics.dmi'
	icon_state = "cryopod"
	base_icon_state = "cryopod"
	anchored = TRUE
	can_weld_shut = FALSE
	can_install_electronics = FALSE
	crate_climb_time = 0
	divable = FALSE
	horizontal = FALSE
	open_sound_volume = 0
	close_sound_volume = 0
	elevation = 0
	elevation_open = 0
	mob_storage_capacity = 1

/obj/structure/closet/crate/freezer/cryo/proc/close_pod(mob/user)
	. = close(user)
	if(!.)
		return FALSE
	visible_message(span_danger("[src] hums and hisses... but then sounds an alarm!"))
	balloon_alert_to_viewers("error!")
	playsound(src, 'sound/machines/terminal/terminal_off.ogg', 70, TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(src), 'sound/machines/defib/defib_failed.ogg', 300, FALSE), 1.5 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(src), 'sound/machines/defib/defib_failed.ogg', 300, FALSE), 2.1 SECONDS)
	return TRUE

/obj/structure/closet/crate/freezer/cryo/update_icon_state()
	base_icon_state = opened ? "cryopod-" : "cryopod"
	return ..()

/obj/structure/closet/crate/freezer/cryo/mouse_drop_receive(mob/living/target, mob/user, params)
	if(!istype(target) || !ismob(target) || isanimal(target) || !istype(user.loc, /turf) || target.buckled)
		return

	if(LAZYLEN(target.buckled_mobs) > 0)
		if(target == user)
			to_chat(user, span_danger("You can't fit into the cryopod while someone is buckled to you."))
		else
			to_chat(user, span_danger("You can't fit [target] into the cryopod while someone is buckled to them."))
		return

	if(!opened)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(target == user)
		if(tgui_alert(target, "Would you like to enter cryosleep?", "Enter Cryopod?", list("Yes", "No")) != "Yes")
			return
		var/turf/freezer_turf = get_turf(src)
		target.forceMove(freezer_turf)
		close_pod(user)
		balloon_alert(user, "error!")
	else
		. = ..()
		if(. && close_pod(user))
			balloon_alert(user, "error!")

