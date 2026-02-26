extends StaticBody2D
# This script controls a breakable floor object.
# The floor will only break if the player lands on it while in "heavy" mode
# and falling fast enough. Otherwise, it stays intact.


@export var breakVelocity := 800.0
# Minimum downward velocity required to break the floor.
# @export allows you to change this value from the Godot editor.
# This acts like a "strength threshold" — the player must hit the floor hard enough.


@onready var collider: CollisionShape2D = $CollisionShape2D
# Reference to the CollisionShape2D that makes the floor solid.
# We disable this when the floor breaks so the player falls through.


@onready var sprite: Sprite2D = $Sprite2D
# Reference to the Sprite2D that visually represents the floor.
# We hide this when the floor breaks.


var broken = false
# Tracks whether the floor has already been broken.
# Prevents the break logic from running multiple times.


func _breakfloor():
	# This function handles the breaking of the floor.

	broken = true
	# Mark the floor as broken so it cannot break again.

	collider.set_deferred("disabled", true)
	# Disable collision so the floor no longer blocks movement.
	# set_deferred ensures this happens safely outside the physics step.

	sprite.set_deferred("visible", false)
	# Hide the sprite so the floor disappears visually.

	$Area2D.set_deferred("monitoring", false)
	# Disable the Area2D detection so it no longer checks for bodies.
	# This improves performance and prevents duplicate triggers.


func _on_area_2d_body_entered(body):
	# This function runs when a physics body enters the floor's detection Area2D.
	# It checks whether the body meets all requirements to break the floor.

	if broken:
		# If the floor is already broken, do nothing.

		print("already broken")
		return


	if not body.is_in_group("player"):
		# Ignore anything that is not the player (enemies, objects, etc.)

		print("this is not the player")
		return


	if not body.heavy:
		# Only allow breaking if the player is in heavy mode.
		# This connects to your STONE slam ability.

		print("the player is't heavy enough")
		return


	if body.velocity.y > breakVelocity:
		# Checks the player's downward velocity.
		# In Godot, positive Y velocity means falling downward.
		# This condition ensures the player must be falling fast enough.

		print("player is not fast enough")
		return


	_breakfloor()
	# If all conditions pass, break the floor.
