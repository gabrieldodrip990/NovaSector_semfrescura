/mob/living/silicon/robot/examine(mob/user)
	. = list()
	if(desc)
		. += "[desc]"

	var/model_name = model ? "\improper [model.name]" : "\improper Default"
	// Bluemoon edit - Cyborg gender
	. += "[p_They()] [p_are()] currently <b>\a [model_name]-type cyborg.</b>"

	var/obj/act_module = get_active_held_item()
	if(act_module)
		// Bluemoon edit - Cyborg gender
		. += "[p_They()] [p_are()] holding [icon2html(act_module, user)] \a [act_module]."
	. += get_status_effect_examinations()
	if (getBruteLoss())
		if (getBruteLoss() < maxHealth*0.5)
			// Bluemoon edit - Cyborg gender
			. += span_warning("[p_They()] look[p_s()] slightly dented.")
		else
			// Bluemoon edit - Cyborg gender
			. += span_boldwarning("[p_They()] look[p_s()] severely dented!")
	if (getFireLoss() || getToxLoss())
		var/overall_fireloss = getFireLoss() + getToxLoss()
		if (overall_fireloss < maxHealth * 0.5)
			// Bluemoon edit - Cyborg gender
			. += span_warning("[p_They()] look[p_s()] slightly charred.")
		else
			// Bluemoon edit - Cyborg gender
			. += span_boldwarning("[p_They()] look[p_s()] severely burnt and heat-warped!")
	if (health < -maxHealth*0.5)
		// Bluemoon edit - Cyborg gender
		. += span_warning("[p_They()] look[p_s()] barely operational.")
	if (fire_stacks < 0)
		// Bluemoon edit - Cyborg gender
		. += span_warning("[p_They()] [p_are()] covered in water.")
	else if (fire_stacks > 0)
		// Bluemoon edit - Cyborg gender
		. += span_warning("[p_They()] [p_are()] coated in something flammable.")

	if(opened)
		// Bluemoon edit - Cyborg gender
		. += span_warning("[p_Their()] cover is open and the power cell is [cell ? "installed" : "missing"].")
	else
		// Bluemoon edit - Cyborg gender
		. += "[p_Their()] cover is closed[locked ? "" : ", and look[p_s()] unlocked"]."

	if(cell && cell.charge <= 0)
		// Bluemoon edit - Cyborg gender
		. += span_warning("[p_Their()] battery indicator is blinking red!")

	switch(stat)
		if(CONSCIOUS)
			if(shell)
				// Bluemoon edit - Cyborg gender
				. += "[p_They()] appear[p_s()] to be an [deployed ? "active" : "empty"] AI shell."
			else if(!client)
				// Bluemoon edit - Cyborg gender
				. += "[p_They()] appear[p_s()] to be in stand-by mode." //afk
		if(SOFT_CRIT, UNCONSCIOUS, HARD_CRIT)
			// Bluemoon edit - Cyborg gender
			. += span_warning("[p_They()] doesn't seem to be responding.")
		if(DEAD)
			// Bluemoon edit - Cyborg gender
			. += span_deadsay("[p_They()] look[p_s()] like [p_their()] system is corrupted and requires a reset.")
	//NOVA EDIT ADDITION BEGIN - CUSTOMIZATION
	. += get_silicon_flavortext()
	//NOVA EDIT ADDITION END

	. += ..()
