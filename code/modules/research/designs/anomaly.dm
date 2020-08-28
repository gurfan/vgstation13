
//6: max obtainable, by deconstructing a third encrypted HDD
//5: obtainable by deconstructing another rare find OR another encrypted HDD
//4: obtainable by deconstructing some rare finds OR by deconstructing an encrypted HDD
//3:
//2: easily obtainabled by deconstructing small artifacts
//1:
//0:

//ANOMALY LEVEL 1
/datum/design/scienceglasses
	name = "Science Goggles"
	desc = "You expect those glasses to protect you from science-related hazards. Maybe you shouldn't."
	id = "scienceglasses"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 700, MAT_GLASS = 2000)
	category = "Anomaly"
	build_path = /obj/item/clothing/glasses/science

/datum/design/depth_scanner
	name = "Depth Analysis Scanner"
	desc = "Used to check spatial depth and density of rock outcroppings."
	id = "depth_scanner"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 1000, MAT_GLASS = 2000)
	category = "Anomaly"
	build_path = /obj/item/device/depth_scanner

/datum/design/measuring_tape
	name = "Measuring Tape"
	desc = "A coiled metallic tape used to check dimensions and lengths."
	id = "measuring_tape"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 3000, MAT_GLASS = 500)
	category = "Anomaly"
	build_path = /obj/item/device/measuring_tape

/datum/design/core_sampler
	name = "Core Sampler"
	desc = "Used to extract geological core samples."
	id = "core_sampler"
	req_tech = list(Tc_MATERIALS = 1, Tc_ANOMALY = 1)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 4000, MAT_GLASS = 700)
	category = "Anomaly"
	build_path = /obj/item/device/core_sampler

/datum/design/anobattery
	name = "Anomaly Power Battery"
	desc = "Used to store anomalous energies."
	id = "ano_battery"
	req_tech = list(Tc_POWERSTORAGE = 1, Tc_ANOMALY = 1)
	materials = list(MAT_IRON = 3500, MAT_GLASS = 3500)
	category = "Anomaly"
	build_path = /obj/item/weapon/anobattery

//ANOMALY LEVEL 2
/datum/design/phazon_glowstick
	name = "Phazon Glowstick"
	desc = "A glowstick filled with phazon material that will change colors upon agitation. It has a string on it so you can wear it."
	id = "phazon_glowstick"
	req_tech = list(Tc_MATERIALS = 6, Tc_ANOMALY = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS=1000, MAT_PHAZON=20)
	category = "Anomaly"
	build_path = /obj/item/clothing/accessory/glowstick/phazon


//ANOMALY LEVEL 3
/datum/design/xenoarch_scanner
	name = "Xenoarchaeology digsite locator"
	desc = "Shows digsites in vicinity, whether they're hidden or not."
	id = "xenoarch_scanner"
	req_tech  =list(Tc_MAGNETS = 2, Tc_ANOMALY = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS=1000, MAT_IRON = 1000)
	category = "Anomaly"
	build_path = /obj/item/device/xenoarch_scanner

/datum/design/anobattery_high
	name = "Refined Anomaly Power Battery"
	desc = "Used to store more anomalous energies."
	id = "ano_battery_high"
	req_tech = list(Tc_POWERSTORAGE = 4, Tc_ANOMALY = 3)
	materials = list(MAT_IRON = 4500, MAT_GLASS = 3500)
	category = "Anomaly"
	build_path = /obj/item/weapon/anobattery/high


//ANOMALY LEVEL 4
/datum/design/xenoarch_scanner_adv//lets you find large artifacts buried in view
	name = "Advanced xenoarchaeology digsite locator"
	desc = "Shows digsites in vicinity, whether they're hidden or not. Shows you their material via highlighting them a specific colour"
	id = "xenoarch_scanner_adv"
	req_tech  =list(Tc_MAGNETS = 3, Tc_ANOMALY = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS=2500, MAT_IRON = 2500, MAT_PLASMA = 300)
	category = "Anomaly"
	build_path = /obj/item/device/xenoarch_scanner/adv

/datum/design/anodevice
	name = "Anomaly Power Utilizer"
	desc = "Holds anomaly power batteries and is capable of activating effects stored within them."
	id = "anodevice"
	req_tech  =list(Tc_POWERSTORAGE = 5, Tc_ANOMALY = 4, Tc_PROGRAMMING = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5500, MAT_GLASS = 5500, MAT_DIAMOND = 5500, MAT_URANIUM = 5500)
	category = "Anomaly"
	build_path = /obj/item/weapon/anodevice

//ANOMALY LEVEL 5
/datum/design/ano_scanner//easily lets you quickly find every large artifact buried on the Z-Level
	name = "Alden-Saraspova Counter"
	desc = "Aids in triangulation of exotic particles. Useful to locate large alien artifacts."
	id = "ano_scanner"
	req_tech = list(Tc_MATERIALS = 6, Tc_BLUESPACE = 4, Tc_ANOMALY = 5)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 2500, MAT_GLASS = 2500, MAT_GOLD = 200, MAT_URANIUM = 200)
	category = "Anomaly"
	build_path = /obj/item/device/ano_scanner

/datum/design/anobattery_hyper
	name = "Plasma-Lined Anomaly Power Battery"
	desc = "Used to store even more anomalous energies."
	id = "ano_battery_hyper"
	req_tech = list(Tc_POWERSTORAGE = 6, Tc_ANOMALY = 5)
	materials = list(MAT_IRON = 5500, MAT_GLASS = 3500, MAT_DIAMOND = 1500, MAT_PLASMA = 15000)
	category = "Anomaly"
	build_path = /obj/item/weapon/anobattery/hyper

//ANOMALY LEVEL 6
/datum/design/anobattery_ultra
	name = "Bluespace Anomaly Power Battery"
	desc = "Used to store the most unstable of anomalous energies."
	id = "ano_battery_ultra"
	req_tech = list(Tc_POWERSTORAGE = 6, Tc_ANOMALY = 5, Tc_MATERIALS = 9)	//Require
	materials = list(MAT_IRON = 7000, MAT_GLASS = 3500, MAT_SILVER = 5500, MAT_GOLD = 5500, MAT_PHAZON = 3500)
	category = "Anomaly"
	build_path = /obj/item/weapon/anobattery/ultra

