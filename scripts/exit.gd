extends Area2D
@export var level := 1
var player_inside := false


func _reload_scene():
	get_tree().reload_current_scene()
func _next_scene():
	if level == 1:
		get_tree().change_scene_to_file("res://scenes/levels/lv_1_2.tscn")
	elif level == 2:
		get_tree().change_scene_to_file("res://scenes/levels/lv_1_3.tscn")
	elif level == 3:
		get_tree().change_scene_to_file("res://scenes/levels/lv_1_4.tscn")
	else:
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_inside == true:
		if Input.is_action_just_pressed("switch"):
			call_deferred("_next_scene")



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true




func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		
