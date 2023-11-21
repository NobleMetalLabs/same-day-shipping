class_name SettingsPanel
extends PopupPanel

@onready var master_vol_slider : Slider = $"%MASTER-VOL-SLIDER"
@onready var music_vol_slider : Slider = $"%MUSIC-VOL-SLIDER"
@onready var sfx_vol_slider : Slider = $"%SFX-VOL-SLIDER"

@onready var mouse_sens_slider : Slider = $"%MOUSE-SENS-SLIDER"

func _ready():
	master_vol_slider.drag_ended.connect(
		func(changed):
			if not changed: return
			var value = master_vol_slider.value
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Master"),
				value
			)
	)
	music_vol_slider.drag_ended.connect(
		func(changed):
			if not changed: return
			var value = master_vol_slider.value
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Master"),
				value
			)
	)
	sfx_vol_slider.drag_ended.connect(
		func(changed):
			if not changed: return
			var value = master_vol_slider.value
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Master"),
				value
			)
	)
