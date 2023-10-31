#class_name GameStateManager
extends Node

var game_seed : int = 0
var current_game_zones : Array[PackageZone]

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_P) and just_pressed:
		PackageZoneManager.reset()
		GameStopwatch.reset()
		get_tree().reload_current_scene()

func start_game(zone_count, _seed = null):
	if not _seed:
		randomize()
		_seed = randi()
	game_seed = hash(_seed)
	current_game_zones = PackageZoneManager.generate_zone_list(zone_count)
	PackageZoneManager.set_active_zones(current_game_zones)

func register_package_zone_completion(zone : PackageZone):
	print("Player reached '%s'." % [zone.zone_name])
	zone.set_enabled(false)
	current_game_zones.erase(zone)
	if len(current_game_zones) == 0:
		end_game()

func end_game():
	GameStopwatch.stop()
	print("You win! Your time was: %s" % [GameStopwatch.time])
