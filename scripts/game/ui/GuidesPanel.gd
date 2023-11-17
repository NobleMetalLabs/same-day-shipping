class_name GuidesPanel
extends Panel

@export var guides : Array[Guide] = []

@onready var sidebar_button : Button = $"%SIDEBAR-BUTTON"
@onready var content_title : Label = $"%CONTENT-TITLE"
@onready var content_text : Label = $"%CONTENT-TEXT"

func _ready():
	prepare_guides()

func prepare_guides():
	sidebar_button.visible = false

	for guide in guides:
		var new_button : Button = sidebar_button.duplicate()
		sidebar_button.get_parent().add_child(new_button)
		new_button.visible = true
		new_button.text = guide.title
		new_button.pressed.connect(
			func():
				display_guide(guide)
		)

func display_guide(guide : Guide):
	content_title.text = guide.title
	content_text.text = guide.text
