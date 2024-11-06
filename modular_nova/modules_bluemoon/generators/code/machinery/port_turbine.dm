// Bluemoon edit - Portable turbine generator
#define MAXIMUM_TURBINE_RPM 35000
#define MINIMUM_TURBINE_PRESSURE 0.01
#define PRESSURE_MAX(value)(max((value), MINIMUM_TURBINE_PRESSURE))
///Maximum amount of moles that can be transferred from the fuel tank per tick
#define FUEL_DRAIN_MAX 20

// Reaction tank for combusting gas.
/obj/item/tank/port_turbine_reactor
	volume = 280

// Post-expansion tank for cooling hot gas.
/obj/item/tank/port_turbine_expander
	volume = 1000

/obj/machinery/power/port_turbine
	name = "portable turbine generator"
	desc = "A device which combusts gas to spin a turbine and produce power."
	icon = 'modular_nova/modules/aesthetics/emitter/icons/emitter.dmi'
	icon_state = "ca"
	max_integrity = 350
	integrity_failure = 0.2
	use_power = NO_POWER_USE
	can_atmos_pass = ATMOS_PASS_DENSITY
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT

	/// Soundloop for while the turbine is turned on
	var/datum/looping_sound/port_turbine/soundloop
	///Stores the loaded tank instance
	var/obj/item/tank/internals/plasma/fuel_tank = null
	///Stores the actively combusting gas mixture
	var/obj/item/tank/port_turbine_reactor/reactor_tank = new
	///Cools the hot exhaust gas mixture
	var/obj/item/tank/port_turbine_expander/expander_tank = new
	///Is the generator working?
	var/active = FALSE
	///Moles of gas removed per tick
	var/drain_rate = 12
	///Kinetic speed of the turbine rotor
	var/rpm = 0
	///Amount of power the generator is producing
	var/produced_energy

/obj/machinery/power/port_turbine/examine(mob/user)
	. = ..()
	if(!active)
		. += span_notice("<b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>combustible gas</b>.\"")
	. += span_notice("[src]'s display states that it is producing <b>[display_energy(produced_energy)]</b>.")

/obj/machinery/power/port_turbine/anchored
	anchored = TRUE

/obj/machinery/power/port_turbine/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

// Transfers gas from the attached tank to the internal tank and ignites it
/obj/machinery/power/port_turbine/process_atmos()
	if(!active || (machine_stat & BROKEN) || !powered(ignore_use_power = TRUE))
		toggle_power(turn_off = TRUE)
		if(soundloop.loop_started)
			soundloop.stop()
		return PROCESS_KILL

	if(!soundloop.loop_started)
		soundloop.start()

	var/datum/gas_mixture/fuel_mix = fuel_tank.return_air()
	var/datum/gas_mixture/reactor_mix = reactor_tank.return_air()
	var/datum/gas_mixture/expander_mix = expander_tank.return_air()

	var/fuel_moles = fuel_mix.total_moles()
	if(fuel_moles == 0)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)

	// Inject from fuel tank into the reaction tank. Regulate this to increase/decrease the amount of gas moved in.
	var/compressor_work = transfer_gases(fuel_mix, reactor_mix, work_amount_to_remove = 0, intake_size = drain_rate / FUEL_DRAIN_MAX)

	if(reactor_mix.total_moles() == 0)
		toggle_power(turn_off = TRUE)
		return

	// Combust gas inside the reaction tank.
	reactor_mix.temperature = max(reactor_mix.temperature, FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
	reactor_mix.react()

	//The turbine expands the exhaust gas from 200 L to 1000 L in order to cool it down.
	var/turbine_work = transfer_gases(reactor_mix, expander_mix, compressor_work)

	//Calculate final power output based on how much exhaust gas was ejected
	var/datum/gas_mixture/ejected_gases = expel_gases(expander_mix)
	if(!ejected_gases) //output turf was blocked with high pressure/temperature gases or by some structure so no power generated
		rpm = 0
		produced_energy = 0
		return

	var/work_done =  QUANTIZE(ejected_gases.total_moles()) * R_IDEAL_GAS_EQUATION * ejected_gases.temperature * log(fuel_mix.return_pressure() / PRESSURE_MAX(ejected_gases.return_pressure()))
	//removing the work needed to move the compressor but adding back the turbine work that is the one generating most of the power.
	work_done = max(work_done - compressor_work * TURBINE_COMPRESSOR_STATOR_INTERACTION_MULTIPLIER - turbine_work, 0)
	//calculate final acheived rpm
	rpm = work_done / TURBINE_RPM_CONVERSION
	rpm = FLOOR(min(rpm, MAXIMUM_TURBINE_RPM), 1)
	//add energy into the grid, also use part of it for turbine operation
	produced_energy = rpm * TURBINE_ENERGY_RECTIFICATION_MULTIPLIER * TURBINE_RPM_CONVERSION
	add_avail(produced_energy)

	. = ..()

/**
 * input_mix - The gas from the environment or from another part of the turbine.
 * output_mix - The gas that got pumped into this part from the input mix. Ideally should be same as input mix but varying texmperatur & pressures can cause varying results.
 * work_amount_to_remove - The amount of work to subtract from the actual work done to pump in the input mixture. For e.g. if gas was transfered from the inlet compressor to the rotor we want to subtract the work done by the inlet from the rotor to get the true work done.
 * intake_size - the percentage of gas to be fed into an turbine part, controlled by turbine computer for inlet compressor only
 */
/obj/machinery/power/port_turbine/proc/transfer_gases(datum/gas_mixture/input_mix, datum/gas_mixture/output_mix, work_amount_to_remove, intake_size = 1)
	// Pump gases. If no gases were transferred then no work was done.
	var/output_pressure = PRESSURE_MAX(output_mix.return_pressure())
	var/datum/gas_mixture/transferred_gases = input_mix.pump_gas_to(output_mix, input_mix.return_pressure() * intake_size)
	if(!transferred_gases)
		return 0

	// Compute work done
	var/work_done = QUANTIZE(transferred_gases.total_moles()) * R_IDEAL_GAS_EQUATION * transferred_gases.temperature * log((transferred_gases.volume * PRESSURE_MAX(transferred_gases.return_pressure())) / (output_mix.volume * output_pressure)) * TURBINE_WORK_CONVERSION_MULTIPLIER
	if(work_amount_to_remove)
		work_done = work_done - work_amount_to_remove

	// Compute temperature & work from temperature if that is a lower value
	var/output_mix_heat_capacity = output_mix.heat_capacity()
	if(!output_mix_heat_capacity)
		return 0
	work_done = min(work_done, (output_mix_heat_capacity * output_mix.temperature - output_mix_heat_capacity * TCMB) / TURBINE_HEAT_CONVERSION_MULTIPLIER)
	output_mix.temperature = max((output_mix.temperature * output_mix_heat_capacity + work_done * TURBINE_HEAT_CONVERSION_MULTIPLIER) / output_mix_heat_capacity, TCMB)
	return work_done

/// push gases from its gas mix to output turf
/obj/machinery/power/port_turbine/proc/expel_gases(datum/gas_mixture/gas_mix)
	var/turf/open/output_turf = loc
	if(QDELETED(output_turf))
		output_turf = get_step(loc, dir)
	//turf is blocked don't eject gases
	if(!TURF_SHARES(output_turf))
		return FALSE

	//eject gases and update turf is any was ejected
	var/datum/gas_mixture/ejected_gases = gas_mix.pump_gas_to(output_turf.air, gas_mix.return_pressure())
	if(ejected_gases)
		output_turf.air_update_turf(TRUE)
		output_turf.update_visuals()

	//return ejected gases
	return ejected_gases

/obj/machinery/power/port_turbine/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tank/internals/plasma))
		if(fuel_tank)
			to_chat(user, span_warning("There's already a gas tank loaded!"))
			return TRUE
		if(panel_open)
			to_chat(user, span_warning("Close the maintenance panel first!"))
			return TRUE
		if(!user.transferItemToLoc(item, src))
			return
		fuel_tank = item
		update_appearance()
	else
		return ..()

/obj/machinery/power/port_turbine/wrench_act(mob/living/user, obj/item/item)
	. = ..()
	if(!active)
		default_unfasten_wrench(user, item)
		return ITEM_INTERACT_SUCCESS
	else
		to_chat(user, span_warning("Turn the generator off first!"))
		return ITEM_INTERACT_BLOCKING

/obj/machinery/power/port_turbine/screwdriver_act(mob/living/user, obj/item/item)
	if(..())
		return TRUE
	if(!fuel_tank)
		default_deconstruction_screwdriver(user, icon_state, icon_state, item)
		return TRUE
	to_chat(user, span_warning("Remove the gas tank first!"))
	return TRUE

/obj/machinery/power/port_turbine/crowbar_act(mob/living/user, obj/item/I)
	if(fuel_tank)
		eject()
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	to_chat(user, span_warning("There isn't a gas tank loaded!"))
	return TRUE

/obj/machinery/power/port_turbine/atom_break(damage_flag)
	. = ..()
	if(.)
		eject()

/obj/machinery/power/port_turbine/proc/eject()
	var/obj/item/tank/internals/plasma/tank = fuel_tank
	if (!tank)
		return
	tank.forceMove(drop_location())
	tank.layer = initial(tank.layer)
	tank.plane = initial(tank.plane)
	fuel_tank = null
	if(active)
		toggle_power()
	else
		update_appearance()

/obj/machinery/power/port_turbine/update_overlays()
	. = ..()
	if(fuel_tank)
		. += "ptank"
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		. += "on" // SKYRAT EDIT CHANGE - ORIGINAL. += fuel_tank ? "on" : "error"

/obj/machinery/power/port_turbine/proc/toggle_power(turn_off = FALSE)
	if(turn_off)
		active = FALSE
	else
		active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
		SSair.start_processing_machine(src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
		SSair.stop_processing_machine(src)
	update_appearance()
	return

/obj/machinery/power/port_turbine/attack_ai(mob/user)
	interact(user)

/obj/machinery/power/port_turbine/attack_paw(mob/user, list/modifiers)
	interact(user)

/obj/machinery/power/port_turbine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableTurbine", name)
		ui.open()

/obj/machinery/power/port_turbine/ui_data()
	var/data = list()

	data["active"] = active


	if(fuel_tank != null)
		data["tank_name"] = capitalize(fuel_tank.name)
		data["fuel_moles"] = fuel_tank.air_contents.total_moles()
		data["fuel_pressure"] = fuel_tank.air_contents.return_pressure()
	else
		data["tank_name"] = "No fuel tank loaded..."
		data["fuel_moles"] = 0
		data["fuel_pressure"] = 0

	data["anchored"] = anchored
	data["connected"] = (powernet == null ? 0 : 1)
	data["ready_to_boot"] = anchored && data["fuel_moles"]
	data["power_generated"] = display_power(energy_to_power(produced_energy), convert = FALSE)
	data["fuel_rate"] = drain_rate
	data["power_available"] = (powernet == null ? 0 : display_power(avail()))
	data["current_heat"] = reactor_tank.air_contents.return_temperature()
	. = data

/obj/machinery/power/port_turbine/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_power")
			toggle_power()
			. = TRUE

		if("eject")
			if(!active)
				eject()
				. = TRUE

		if("lower_power")
			if (drain_rate > 1)
				drain_rate--
				. = TRUE

		if("higher_power")
			if (drain_rate < 20)
				drain_rate++
				. = TRUE

#undef MAXIMUM_TURBINE_RPM
#undef MINIMUM_TURBINE_PRESSURE
#undef PRESSURE_MAX
#undef FUEL_DRAIN_MAX
