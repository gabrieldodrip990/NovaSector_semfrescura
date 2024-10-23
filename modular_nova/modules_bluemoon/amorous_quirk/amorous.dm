/datum/quirk/amorous
	name = "Amorous"
	desc = "You have a more active libido than most people."
	value = 0
	mob_trait = TRAIT_AMOROUS
	gain_text = span_userlove("Your libido is going haywire! It feels like speaking is much harder...")
	lose_text = span_notice("Your mind is free. Your thoughts are pure and innocent once more.")
	medical_record_text = "Subject has permanent hormonal disruption."
	icon = FA_ICON_HEART
	erp_quirk = TRUE

/datum/quirk/amorous/add()
	var/mob/living/carbon/carbon_holder = quirk_holder
	carbon_holder.gain_trauma(/datum/brain_trauma/very_special/amorous, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/amorous/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	carbon_holder.cure_trauma_type(/datum/brain_trauma/very_special/amorous, TRAUMA_RESILIENCE_ABSOLUTE)
