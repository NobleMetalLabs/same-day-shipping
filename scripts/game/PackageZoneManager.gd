#class_name PackageZoneManager
extends Node

var zones : Array[PackageZone] = []

func reset():
	zones = []

func register_package_zone(zone : PackageZone):
	#print("Added ['%s'] to zones" % [zone.zone_name])
	zones.append(zone)

func generate_zone_list(num : int = 5) -> Array[PackageZone]:
	var zcopy = zones.duplicate()
	seed(GameStateManager.game_seed)
	zcopy.shuffle()
	return zcopy.slice(0, num)

func set_active_zones(active_zones : Array[PackageZone]):
	for zone in zones:
		var enabled = zone in active_zones
		zone.set_enabled(enabled)
		# print("%s zone '%s'" % [
		# 	"Enabled" if enabled else "Disabled", 
		# 	zone.zone_name
		# ])


