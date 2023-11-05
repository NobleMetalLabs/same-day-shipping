#class_name GameStopwatch
extends Node

var running : bool = false
var time : float = 0.0
# Called when the node enters the scene tree for the first time.

func reset():
	time = 0.0
	running = false

func start():
	running = true

func restart():
	reset()
	running = true

func stop():
	running = false

func _process(delta):
	if running:
		time += delta