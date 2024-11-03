/datum/map_template/shuttle/crimson
	port_id = "crimson"
	who_can_purchase = null
	suffix = "freighter"
	name = "SEV 'Crimson'"

/area/shuttle/crimson
	name = "SEV 'Crimson'"
	requires_power = TRUE
	fire_detect = FALSE

/obj/docking_port/stationary/crimson
	name = "Refueling Station: Port 9"
	shuttle_id = "crimson_home"
	roundstart_template = /datum/map_template/shuttle/crimson
	height = 39
	width = 23
	dwidth = 1
	dheight = 25

/obj/docking_port/mobile/crimson
	callTime = 3 MINUTES
	can_move_docking_ports = TRUE
	shuttle_id = "crimson"
	launch_status = 0
	movement_force = list("KNOCKDOWN"=0,"THROW"=0)
	name = "SEV 'Crimson'"
	port_direction = SOUTH
	preferred_direction = NORTH
