class_name FocusAwareSpinbox
extends SpinBox

func _input(event):
	if not event is InputEventMouseButton: return
	if not event.pressed: return

	var lineedit = self.get_line_edit()
	if self.has_focus():
		var control_rect = self.get_rect()
		control_rect.position = Vector2.ZERO
		var local_rect = control_rect
		if local_rect.has_point(get_local_mouse_position()): return
		self.release_focus()
		clicked_out_of.emit()
	elif lineedit.has_focus():
		var control_rect = lineedit.get_rect()
		control_rect.position = Vector2.ZERO
		var local_rect = control_rect
		if local_rect.has_point(get_local_mouse_position()): return
		lineedit.release_focus()
		clicked_out_of.emit()
	else:
		return
	

signal clicked_out_of()