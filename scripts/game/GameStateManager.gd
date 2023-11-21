#class_name GameStateManager
extends Node

var game_seed : int = 0
var game_zone_count : int = 5
var current_game_zones : Array[PackageZone]
var game_in_progress : bool = false
var exploring : bool = false

signal explore()
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
	UI.win_panel.finished.connect(end_game)

func _input(event):
	if get_viewport().gui_get_focus_owner() != null: return
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_R) and just_pressed:
		restart_game()
		return
	if Input.is_key_pressed(KEY_E) and just_pressed:
		start_explore()

func start_explore():
	if game_in_progress:
		start_postgame()
	explore.emit()
	exploring = true
	UI.practice_controls.show()
	GameStopwatch.reset()
	UI.new_game_panel.hide()
	return

func start_game(zone_count = 5, _seed = null, rehash = true):
	print("Starting %s zone game with seed %s." % [zone_count, _seed])
	if not _seed:
		randomize()
		_seed = randi()
	game_seed = hash(_seed) if rehash else _seed
	game_zone_count = zone_count
	current_game_zones = PackageZoneManager.generate_zone_list(zone_count)
	PackageZoneManager.set_active_zones(current_game_zones)
	UI.countdown_panel.start_countdown()
	GameStopwatch.reset()
	game_in_progress = true
	exploring = false
	UI.practice_controls.hide()
	pregame_started.emit()

func restart_game():
	if not game_in_progress: return
	start_game(game_zone_count, game_seed, false)

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
	print("Player wins!")
	GameStopwatch.stop()
	PackageZoneManager.set_active_zones([])
	UI.win_panel.display_time(GameStopwatch.time)
	postgame_started.emit()

func end_game():
	game_in_progress = false
	start_explore()
