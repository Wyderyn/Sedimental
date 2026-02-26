extends Area2D
# This script is attached to an Area2D that acts as a level exit or portal.
# When the player enters the area and presses the "switch" key, the scene changes
# to the next level or quits the game if there are no more levels.


@export var level := 1
# Indicates the current level number.
# @export allows you to set this in the Godot editor for different exit areas.

var player_inside := false
# Tracks whether the player is currently inside the area.
# Used to allow level progression only when the player is in the exit zone.


# =========================
# SCENE MANAGEMENT FUNCTIONS
# =========================
func _reload_scene():
	# Reloads the current scene.
	# Useful for resetting the level if needed.
	get_tree().reload_current_scene()


func _next_scene():
	# Changes the scene based on the current level number.
	# This handles progression to the next level or quitting the game if finished.

	if level == 1:
		get_tree().change_scene_to_file("res://scenes/levels/lv_1_2.tscn")
		# Load level 2 from file.

	elif level == 2:
		get_tree().change_scene_to_file("res://scenes/levels/lv_1_3.tscn")
		# Load level 3 from file.

	elif level == 3:
		get_tree().change_scene_to_file("res://scenes/levels/lv_1_4.tscn")
		# Load level 4 from file.

	else:
		get_tree().quit()
		# No more levels, exit the game.


# =========================
# FRAME UPDATE
# =========================
func _process(_delta: float) -> void:
	# Runs every frame.
	# _delta is the time elapsed since the last frame.

	if player_inside == true:
		# Only allow the player to trigger scene change if they are inside the Area2D.

		if Input.is_action_just_pressed("switch"):
			# If the player presses the "switch" key while inside, go to the next scene.
			call_deferred("_next_scene")
			# call_deferred ensures the scene change happens safely after the current frame.


# =========================
# AREA SIGNALS
# =========================
func _on_body_entered(body: Node2D) -> void:
	# Triggered when any body enters the Area2D.

	if body.is_in_group("player"):
		# Only respond to the player.
		player_inside = true
		# Player is now inside the exit area.


func _on_body_exited(body: Node2D) -> void:
	# Triggered when any body exits the Area2D.

	if body.is_in_group("player"):
		# Only respond to the player.
		player_inside = false
		# Player has left the exit area.
