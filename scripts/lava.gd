extends StaticBody2D

func _restart():
	if not is_inside_tree():
		return
	get_tree().reload_current_scene()
	
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		if body.currentMat == body.Mat.AMBER:
			body.inLava = true
			return
		else:
			call_deferred("_restart")
func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		if body.currentMat == body.Mat.AMBER:
			body.inLava = false
			return
		else:
			call_deferred("_restart")
