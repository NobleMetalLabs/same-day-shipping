#class_name GameStateManager
extends Node

var game_seed : int = 0
var game_zone_count : int = 5
var current_game_zones : Array[PackageZone]
var game_in_progress : bool = false

signal pregame_started()
signal game_started()
signal postgame_started()
signal game_ended()

func _ready():
	UI.new_game_panel.new_game_requested.connect(
		func(game_options : Dictionary):
			GameStateManager.start_game(
				game_options["destination_count"],
				game_options["seed"]
			)
	)
	UI.countdown_panel.countdown_finished.connect(end_pregame)
	
func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_R) and just_pressed:
		restart_game()

func start_game(zone_count = 5, _seed = null):
	if not _seed:
		randomize()
		_seed = randi()
	game_seed = hash(_seed)
	game_zone_count = zone_count
	current_game_zones = PackageZoneManager.generate_zone_list(zone_count)
	PackageZoneManager.set_active_zones(current_game_zones)
	UI.countdown_panel.start_countdown()
	GameStopwatch.reset()
	game_in_progress = true
	pregame_started.emit()

func restart_game():
	start_game(game_zone_count, game_seed)

func end_pregame():
	GameStopwatch.start()
	game_started.emit()

func register_package_zone_completion(zone : PackageZone):
	print("Player reached '%s'." % [zone.zone_name])
	zone.set_enabled(false)
	current_game_zones.erase(zone)
	if len(current_game_zones) == 0:
		start_postgame()

func start_postgame():
	GameStopwatch.stop()
	print("You win! Your time was: %s" % [GameStopwatch.time])
	postgame_started.emit()

func end_game():
	game_in_progress = false
	game_ended.emit()
