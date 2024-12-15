// Bluemoon edit - Remove membership and donator restrictions
/datum/preferences/refresh_membership()
	unlock_content = TRUE
	donator_status = TRUE
	max_save_slots = 50
