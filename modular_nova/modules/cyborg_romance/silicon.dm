#define AROUSED_ALERT "aroused"
#define AROUSED_SMALL "small"
#define AROUSED_MEDIUM "medium"
#define AROUSED_HIGH "high"
#define AROUSED_MAX "max"

/mob/living/silicon/robot
	var/arousal = 0
	var/pleasure = 0
	var/pain = 0

	var/pain_limit = 0
	var/arousal_status = AROUSAL_NONE

	var/refractory_period


/mob/living/silicon/robot/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/interactable)
	if(CONFIG_GET(flag/disable_erp_preferences))
		verbs -= /mob/living/carbon/human/verb/climax_verb

/mob/living/silicon/robot/Life(seconds_per_tick, times_fired)
	. = ..()
	if(client?.prefs?.read_preference(/datum/preference/toggle/erp))
		handle_arousal(seconds_per_tick, times_fired)

/// Sends an icon to the screen that gives an approximate indication of the mob's arousal.
/mob/living/silicon/robot/proc/throw_arousal_alert(level, atom/movable/screen/alert/aroused/arousal_alert)
	throw_alert(AROUSED_ALERT, /atom/movable/screen/alert/aroused)
	arousal_alert?.icon_state = "arousal_[level]"
	arousal_alert?.update_icon()

/// Sends an icon to the screen that gives an approximate indication of the mob's pain. Looks like spikes/barbed wire.
/mob/living/silicon/robot/proc/overlay_pain(level, atom/movable/screen/alert/aroused/arousal_alert)
	arousal_alert?.cut_overlay(arousal_alert.pain_overlay)
	arousal_alert?.pain_level = level
	arousal_alert?.pain_overlay = arousal_alert.update_pain()
	arousal_alert?.add_overlay(arousal_alert.pain_overlay)
	arousal_alert?.update_overlays()

/// Sends an icon to the screen that gives an approximate indication of the mob's pleasure. Looks like a pink-white border on the arousal alert heart.
/mob/living/silicon/robot/proc/overlay_pleasure(level, atom/movable/screen/alert/aroused/arousal_alert)
	arousal_alert?.cut_overlay(arousal_alert.pleasure_overlay)
	arousal_alert?.pleasure_level = level
	arousal_alert?.pleasure_overlay = arousal_alert.update_pleasure()
	arousal_alert?.add_overlay(arousal_alert.pleasure_overlay)
	arousal_alert?.update_overlays()

/// Handles throwing the arousal alerts to screen.
/mob/living/silicon/robot/proc/handle_arousal(atom/movable/screen/alert/aroused)
	if(!client?.prefs?.read_preference(/datum/preference/toggle/erp))
		return

	var/atom/movable/screen/alert/aroused/arousal_alert = alerts[AROUSED_ALERT]

	var/alert_state
	switch(arousal)
		if(-INFINITY to AROUSAL_MINIMUM_DETECTABLE)
			clear_alert(AROUSED_ALERT, /atom/movable/screen/alert/aroused)
			if(arousal < AROUSAL_MINIMUM)
				arousal = AROUSAL_MINIMUM // To prevent massively negative values that break the lewd system for some.
		if(AROUSAL_MINIMUM_DETECTABLE to AROUSAL_LOW)
			alert_state = AROUSED_SMALL
		if(AROUSAL_LOW to AROUSAL_MEDIUM)
			alert_state = AROUSED_MEDIUM
		if(AROUSAL_HIGH to AROUSAL_AUTO_CLIMAX_THRESHOLD)
			alert_state = AROUSED_HIGH
		if(AROUSAL_AUTO_CLIMAX_THRESHOLD to INFINITY) //to prevent that 101 arousal that can make icon disappear or something.
			alert_state = AROUSED_MAX
	if(alert_state)
		throw_arousal_alert(alert_state, arousal_alert)
		alert_state = null

	switch(pain)
		if(-INFINITY to AROUSAL_MINIMUM_DETECTABLE) //to prevent same thing with pain
			arousal_alert?.cut_overlay(arousal_alert.pain_overlay)
			if(pain < AROUSAL_MINIMUM)
				pain = AROUSAL_MINIMUM // To prevent massively negative values that break the lewd system for some.
		if(AROUSAL_MINIMUM_DETECTABLE to AROUSAL_LOW)
			alert_state = AROUSED_SMALL
		if(AROUSAL_LOW to AROUSAL_MEDIUM)
			alert_state = AROUSED_MEDIUM
		if(AROUSAL_HIGH to AROUSAL_AUTO_CLIMAX_THRESHOLD)
			alert_state = AROUSED_HIGH
		if(AROUSAL_AUTO_CLIMAX_THRESHOLD to INFINITY)
			alert_state = AROUSED_MAX
	if(alert_state)
		overlay_pain(alert_state, arousal_alert)
		alert_state = null

	switch(pleasure)
		if(-INFINITY to AROUSAL_MINIMUM_DETECTABLE) //to prevent same thing with pleasure
			arousal_alert?.cut_overlay(arousal_alert.pleasure_overlay)
			if(pleasure < AROUSAL_MINIMUM)
				pleasure = AROUSAL_MINIMUM // To prevent massively negative values that break the lewd system for some.
		if(AROUSAL_MINIMUM_DETECTABLE to AROUSAL_LOW)
			alert_state = AROUSED_SMALL
		if(AROUSAL_LOW to AROUSAL_MEDIUM)
			alert_state = AROUSED_MEDIUM
		if(AROUSAL_HIGH to AROUSAL_AUTO_CLIMAX_THRESHOLD)
			alert_state = AROUSED_HIGH
		if(AROUSAL_AUTO_CLIMAX_THRESHOLD to INFINITY)
			alert_state = AROUSED_MAX
	if(alert_state)
		overlay_pleasure(alert_state, arousal_alert)

#undef AROUSED_ALERT
#undef AROUSED_SMALL
#undef AROUSED_MEDIUM
#undef AROUSED_HIGH
#undef AROUSED_MAX
