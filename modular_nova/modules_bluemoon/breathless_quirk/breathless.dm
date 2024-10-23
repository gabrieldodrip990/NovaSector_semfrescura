/datum/quirk/breathless
	name = "Breathless"
	desc = "You don't need to breathe, although you still can."
	value = 0
	mob_trait = TRAIT_NOBREATH
	gain_text = span_notice("Your don't feel the need to breathe.")
	lose_text = span_warning("Your feel the need to breathe again!")
	medical_record_text = "Subject doesn't require any respiration."
	icon = FA_ICON_HEAD_SIDE_COUGH_SLASH

/datum/quirk/amorous/add()
	ADD_TRAIT(quirk_holder, TRAIT_NOBREATH, QUIRK_TRAIT)

/datum/quirk/amorous/remove()
	REMOVE_TRAIT(quirk_holder, TRAIT_NOBREATH, QUIRK_TRAIT)
