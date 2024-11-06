#define GENERATOR_SOUNDPATH(filename) "modular_nova/modules_bluemoon/generators/sound/" + ##filename

// Bluemoon edit - Quiet supermatter shard
/datum/looping_sound/supermatter/shard
	volume = 20
	extra_range = 0
	falloff_exponent = 6.6
	falloff_distance = 3

// Bluemoon addition - Custom generator sounds
/datum/looping_sound/turbine
	start_sound = GENERATOR_SOUNDPATH("turbine_spinup.ogg")
	start_length = 4.7 SECONDS
	mid_sounds = list(
		GENERATOR_SOUNDPATH("turbine_run1.ogg") = 1,
		GENERATOR_SOUNDPATH("turbine_run2.ogg") = 1,
		GENERATOR_SOUNDPATH("turbine_run3.ogg") = 1
	)
	mid_length = 1.1 SECONDS
	end_sound = GENERATOR_SOUNDPATH("turbine_spindown.ogg")
	volume = 75

/datum/looping_sound/generator/portable
	start_sound = GENERATOR_SOUNDPATH("generator_start.ogg")
	start_length = 5.2 SECONDS
	mid_sounds = list(GENERATOR_SOUNDPATH("generator_run.ogg") = 1)
	mid_length = 5.1 SECONDS
	end_sound = GENERATOR_SOUNDPATH("generator_stop.ogg")

/datum/looping_sound/port_turbine
	mid_sounds = list(
		GENERATOR_SOUNDPATH("port_turbine_run1.wav") = 1,
		GENERATOR_SOUNDPATH("port_turbine_run2.wav") = 1,
		GENERATOR_SOUNDPATH("port_turbine_run3.wav") = 1,
		GENERATOR_SOUNDPATH("port_turbine_run4.wav") = 1
	)
	mid_length = 3 SECONDS
	volume = 40
	falloff_exponent = 3

#undef GENERATOR_SOUNDPATH
