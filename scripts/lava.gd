extends StaticBody2D
# This script is attached to a StaticBody2D that likely represents lava.
# The lava interacts with the player and either kills them or allows survival
# if they are in the AMBER (flame) material state.


func _restart():
	# This function reloads the current scene (essentially restarting the level).

	if not is_inside_tree():
		# Safety check: if this node is not currently inside the scene tree,
		# we do nothing. This prevents errors if the node is being removed.
		return

	get_tree().reload_current_scene()
	# Reloads the current scene.
	# Used when the player dies by touching lava without protection.


func _on_area_2d_body_entered(body):
	# This function runs when a physics body enters the lava's Area2D.

	if body.is_in_group("player"):
		# Only respond if the entering body is in the "player" group.
		# Prevents enemies or other objects from triggering lava logic.

		if body.currentMat == body.Mat.AMBER:
			# If the player is currently in AMBER material form,
			# they are immune to lava (because flame protects them).

			body.inLava = true
			# Set the player's inLava flag to true.
			# This is used in the player script to track lava state.

			return
			# Stop here — do NOT restart the scene.

		else:
			# If the player is NOT in AMBER form,
			# touching lava should kill them.

			call_deferred("_restart")
			# Restart the level safely using call_deferred.
			# This avoids modifying the scene during physics processing.


func _on_area_2d_body_exited(body):
	# This function runs when a physics body exits the lava's Area2D.

	if body.is_in_group("player"):
		# Again, only respond if it's the player.

		if body.currentMat == body.Mat.AMBER:
			# If the player leaves lava while in AMBER form,
			# remove lava state protection flag.

			body.inLava = false
			# Player is no longer inside lava.

			return

		else:
			# If a non-amber player somehow exits lava,
			# restart the scene again.
			# (This acts as an additional safety check.)

			call_deferred("_restart")
