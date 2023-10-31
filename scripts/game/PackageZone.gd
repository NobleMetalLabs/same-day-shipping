class_name PackageZone
extends Area3D

@export var zone_name : StringName 

func set_enabled(enabled : bool):
	self.set_deferred("monitoring", enabled)
	_set_enabled(enabled)

func _set_enabled(enabled : bool, node : Node = self):
	node.visible = enabled
	for child in node.get_children():
		_set_enabled(enabled, child)

func _ready():
	PackageZoneManager.register_package_zone(self)
	self.body_entered.connect(func(_b):
		GameStateManager.register_package_zone_completion(self)
	)

func register_completion_from_player():
	GameStateManager.register_package_zone_completion(self)