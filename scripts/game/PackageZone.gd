class_name PackageZone
extends Area3D

@export var zone_name : StringName 

func _ready():
	PackageZoneManager.register_package_zone(self)

func register_completion_from_player():
	GameStateManager.register_package_zone_completion(self)