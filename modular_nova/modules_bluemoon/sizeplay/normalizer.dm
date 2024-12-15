// Contains all code pertaining to normalizers, for the purpose of dynamically adjusting someones height.

/// FLOWCHART:
// -Check to see if user is already normalized
// -If they are; return early and alert the user that their action was invalid.
// -If they aren't; grab user.current_size and store it
// -Play VFX/SFX
// -Normalize user with normalize()
// -Update normalized state to true.
// -On removal, check to see if the user is or isn't normalized
// -If they aren't, return and do nothing.
// -If they are, call reverse_normalize()
// -Call adjust_height() using the stored value inside reverse_normalize()
// -Set stored value to NULL
// -Update normalized state to false.
// -Play VFX/SFX

/obj/item/clothing/proc/normalize(mob/living/carbon/human/user, set_value) // Normalize the user to the set size.
	if(user.is_normalized == TRUE)
		to_chat(user, span_notice("The [src] buzzes and flashes red a couple of times. It cannot normalize what is already normalized!"))
		playsound(user, 'sound/machines/buzz/buzz-two.ogg', 20, FALSE)
		return
	else
		playsound(user, 'sound/effects/magic.ogg', 20, FALSE)
		user.adjust_height(src.normalizer_size, 1)
		user.is_normalized = TRUE

/// This needs refactored at some point. Mostly just handling having two normalizer on at once.
/obj/item/clothing/proc/reverse_normalize(mob/living/carbon/human/user) // Reset the user back to their original size
	if(user.is_normalized == FALSE) //If the user is already not normalized; we dont want to do anything that might fuck up their size.
		return
	else
		playsound(user, 'sound/effects/magic.ogg', 20, FALSE)
		user.adjust_height(user.natural_size, 1) //Set them back to their natural size.
		user.is_normalized = FALSE

/obj/item/clothing/proc/adjust_normalizer_size(mob/living/carbon/user, modifiers) //Adjust the currently set size.
	src.normalizer_size = input(user, "Adjust size increment?", "New size", 1) as num
	if(normalizer_size > user.natural_size) // Prompt the user again if they entered an invalid value.
		balloon_alert(user, "[normalizer_size] is to big!")
		playsound(user, 'sound/machines/buzz/buzz-two.ogg', 20, FALSE)
		normalizer_size = 1
	if(normalizer_size < 0.5)
		balloon_alert(user, "[normalizer_size] is to small!")
		normalizer_size = 1

// Normalizer items

// Neckwear

/obj/item/clothing/neck/normalizer/

/obj/item/clothing/neck/normalizer
	name = "normalizer"
	desc = "If you can see this; alert a developer!"
	icon = 'modular_nova/modules/modular_items/lewd_items/icons/obj/lewd_clothing/lewd_neck.dmi'
	worn_icon = 'modular_nova/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_neck.dmi'
	icon_state = "collar_black"

/obj/item/clothing/neck/normalizer/equipped(mob/living/user, slot)
	. = ..()
	if(!ishuman(user) || !(slot & ITEM_SLOT_NECK))
		return FALSE
	normalize(user, src.normalizer_size)

/obj/item/clothing/neck/normalizer/dropped(mob/living/user)
	. = ..()
	reverse_normalize(user)

/obj/item/clothing/neck/normalizer/pendant
	name = "normalizer pendant"
	desc = "A unique looking pendant with a purple stone inset into its center. It seems to have a small screen and a dial on the back."
	icon = 'modular_nova/master_files/icons/obj/clothing/sizeaccessories.dmi'
	worn_icon = 'modular_nova/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_neck.dmi'
	icon_state = "pendant"

/obj/item/clothing/neck/normalizer/pendant/equipped(mob/living/user, slot)
	. = ..()
	if(!ishuman(user) || !(slot & ITEM_SLOT_NECK))
		return FALSE
	normalize(user, src.normalizer_size)

/obj/item/clothing/neck/normalizer/pendant/dropped(mob/living/user)
	. = ..()
	reverse_normalize(user)

/obj/item/clothing/neck/normalizer/collar
	name = "normalizer collar"
	desc = "A unique looking collar with a purple stone inset into its center. It seems to have a small screen and a dial on the back."
	icon = 'modular_nova/master_files/icons/obj/clothing/sizeaccessories.dmi'
	icon_state = "collar"
	worn_icon = 'modular_nova/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_neck.dmi'
	worn_icon_state = "collar_purple"

/obj/item/clothing/neck/normalizer/collar/equipped(mob/living/user, slot)
	. = ..()
	if(!ishuman(user) || !(slot & ITEM_SLOT_NECK))
		return FALSE
	normalize(user, src.normalizer_size)

/obj/item/clothing/neck/normalizer/collar/dropped(mob/living/user)
	. = ..()
	reverse_normalize(user)

/obj/item/clothing/neck/normalizer/attack_self(mob/living/carbon/user, modifiers)
	adjust_normalizer_size(user)

// Ring

/obj/item/clothing/gloves/ring/normalizer
	name = "normalizer ring"
	desc = "A unique looking ring with a purple stone inset into its center. It seems to have a small dial on the back."
	icon = 'modular_nova/master_files/icons/obj/clothing/sizeaccessories.dmi'
	icon_state = "ring"

/obj/item/clothing/gloves/ring/normalizer/equipped(mob/living/user, slot)
	. = ..()
	if(!ishuman(user) || !(slot & ITEM_SLOT_GLOVES))
		return FALSE
	normalize(user, src.normalizer_size)

/obj/item/clothing/gloves/ring/normalizer/dropped(mob/living/user)
	. = ..()
	reverse_normalize(user)

/obj/item/clothing/gloves/ring/normalizer/attack_self(mob/living/carbon/user, modifiers)
	adjust_normalizer_size(user)

// Loadout handlers

/datum/loadout_item/neck/normalizer_pendant
	name = "Normalizer Pendant"
	item_path = /obj/item/clothing/neck/normalizer/pendant

/datum/loadout_item/neck/normalizer_collar
	name = "Normalizer Collar"
	item_path = /obj/item/clothing/neck/normalizer/collar

/datum/loadout_item/gloves
	name = "Normalizer Ring"
	item_path = /obj/item/clothing/gloves/ring/normalizer
