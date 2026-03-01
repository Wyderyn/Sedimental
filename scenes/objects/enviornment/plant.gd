extends StaticBody2D
# This script is attached to a StaticBody2D, which is a physics object that does not move.
# StaticBody2D is typically used for walls, floors, or environmental objects.
# In this case, it represents a plant or object that can be burned and removed,
# and also regrown using a different material ability.


@onready var collider: CollisionShape2D = $CollisionShape2D
# Gets a reference to this object's CollisionShape2D node when the scene loads.
# This collider controls the physical interaction (blocking movement, collisions, etc.).
# We enable/disable this to make the object solid or non-solid.

@onready var sprite: Sprite2D = $Sprite2D
# Gets a reference to the Sprite2D node that visually represents the object.
# We show or hide this sprite depending on whether the object exists visually.

var burnt = false
# Tracks the current state of the object:
# false = object is intact and visible
# true  = object has been burned and removed
# This prevents repeated burn or grow logic from running unnecessarily.


# Called when the object should burn (triggered by flame contact).
func _burn():

	if burnt == false:
		# Only execute burn logic if the object is currently NOT burned.
		# This prevents duplicate disabling or redundant operations.

		burnt = true
		# Update state to burned so future burn attempts are ignored.

		collider.set_deferred("disabled", true)
		# Disable the collision shape so the object no longer blocks movement.
		# set_deferred ensures this change happens safely after the current physics step.

		sprite.set_deferred("visible", false)
		# Hide the sprite so the object visually disappears from the world.

	else:
		return
		# If already burned, do nothing.


func _grow():
	# This function restores the object if it has been burned.
	# Intended to be triggered by the EMERALD material ability.

	if burnt == true:
		# Only regrow if the object is currently burned.
		# Prevents unnecessary enabling if already active.

		burnt = false
		# Update state to intact so it can be burned again later if needed.

		collider.set_deferred("disabled", false)
		# Re-enable collision so the object becomes solid again.

		sprite.set_deferred("visible", true)
		# Make the sprite visible again so the object appears in the world.


# Signal function triggered when another Area2D enters this object's Area2D
func _on_area_2d_area_entered(area):

	if area.is_in_group("amber"):
		# Checks if the entering area belongs to the "amber" group.
		# This is likely the player's flame ability Area2D.
		# Amber ability burns and removes the object.

		_burn()
		# Calls the burn function to destroy/remove the object.


	if area.is_in_group("emerald"):
		# Checks if the entering area belongs to the "emerald" group.
		# This likely represents a regrowth or nature-based ability.

		_grow()
		# Calls the grow function to restore the object.
