// Bluemoon addition - Custom mob size
/// This file contains all the code relating to actually handling size changes, such as modifying the mob's scale transform.
/// Created primarily by gonenoculer5; co-authored by Francinum for assistance with prefkeys and some of the transform arithmetic.

// Size control variables
#define RESIZE_MAX 6 // How big a given mob can be
#define RESIZE_MIN 0.50 // How small a given mob can be

#define RESIZE_SCALE 0 // Scale sprite up or down via update_transform() by scaling_factor
#define RESIZE_SET 1 // Set scale via update_transform() to scaling_factor

/// Bounds-checked wrapper around update_transform for kink reasons.
/mob/living/carbon/proc/adjust_height(scaling_factor = 0, resize_mode = RESIZE_SCALE)
	switch(resize_mode)
		if(RESIZE_SCALE)
			/// Conceptual resulting value after alteration. Used for bounds checking.
			var/new_size = src.current_size * scaling_factor
			if((new_size < RESIZE_MIN) || (new_size > RESIZE_MAX))
				return
		if(RESIZE_SET)
			// Update Transform only takes relative values. We'll need to Math:tm: this into working.
			// First, bounds check the desired size.
			if((scaling_factor < RESIZE_MIN) || (scaling_factor > RESIZE_MAX))
				return
			// Determine the required scaler to reach the target value
			var/target_value = scaling_factor
			// A bit nasty, but just pretend we passed in the correct arg
			scaling_factor = (target_value / current_size)

	// update_transform scales it's current value relatively, so we can just pass in the argument directly.
	src.update_transform(scaling_factor)

/mob/living/carbon/human/examine(mob/user) // Handles the examine text for determining your real height measured in feet.
	. = ..()
	var/t_He = p_They()
	var/height_inches_total = round(12*(current_size * 6)) //Assuming a standard height of 6 feet
	var/final_inches = height_inches_total % 12
	var/final_feet = (height_inches_total - final_inches)/12 //Get the cleaned up feet value.
	. += span_notice("[t_He] appears to be around [final_feet] foot[final_inches ? " [final_inches] inch[final_inches > 1 ? "es": null]" : null] tall.")

// Debug tool for testing/on the fly adjusting size states.
/obj/item/debug/sizebutton
	name = "size button"
	desc = "A strange button that when pushed, grows or shrinks you by a set amount."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "bigred"
	w_class = WEIGHT_CLASS_SMALL
	/// How much we are adjusting the sprite by.
	var/set_size = 0.5
	/// Sets whether or not we are changing our scale, or directly setting the size of the player.
	var/op_mode = RESIZE_SCALE

/obj/item/debug/sizebutton/attack_self(mob/living/carbon/user)
	var/prior_size = user.current_size
	user.adjust_height(set_size, op_mode)
	if(user.current_size > prior_size)
		playsound(src, 'sound/announcer/vox_fem/big.ogg',50,FALSE)
	else
		playsound(src, 'sound/announcer/vox_fem/small.ogg',50,FALSE)

/obj/item/debug/sizebutton/attack_self_secondary(mob/living/carbon/user)
	switch(op_mode) //Handling for changing modes back and forth between RESIZE_SCALE and RESIZE_SET.
		if(0)
			op_mode = RESIZE_SET
			balloon_alert(user, "You change the operating mode to set size.")
		if(1)
			op_mode = RESIZE_SCALE
			balloon_alert(user, "You change the operating mode to scale size.")

/obj/item/debug/sizebutton/click_alt_secondary(mob/living/carbon/user)
	set_size = input(user, "Adjust size increment?", "New size", set_size) as num
