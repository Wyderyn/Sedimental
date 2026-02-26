extends StaticBody2D
# This script is attached to a StaticBody2D, which is a physics object that does not move.
# StaticBody2D is typically used for walls, floors, or environmental objects.
# In this case, it represents a plant or object that can be burned and removed.


@onready var collider: CollisionShape2D = $CollisionShape2D
# Gets a reference to this object's CollisionShape2D node when the scene loads.
# This collider is what allows the object to physically block or interact with other bodies.
# We store it in a variable so we can disable it later when the object burns.


@onready var sprite: Sprite2D = $Sprite2D
# Gets a reference to the visual Sprite2D node.
# This sprite is what the player actually sees on screen.
# We will hide it when the object burns.


var burnt = false
# Tracks whether this object has already been burned.
# Prevents the burn logic from running multiple times.


# Called when the object should burn (triggered by flame contact).
func _burn():

	if burnt == false:
		# Only run burn logic if the object has NOT already burned.

		burnt = true
		# Mark the object as burned so this cannot happen again.

		collider.set_deferred("disabled", true)
		# Disables the collision shape.
		# set_deferred is used because physics objects cannot safely change collision
		# state during collision processing — this schedules it safely for later.

		sprite.set_deferred("visible", false)
		# Hides the sprite visually, making it look destroyed or removed.

	else:
		return
		# If already burned, do nothing.


# Signal function triggered when another Area2D enters this object's Area2D
func _on_area_2d_area_entered(area):

	if area.is_in_group("amber"):
		# Checks if the entering area belongs to the "amber" group.
		# Your flame ability likely has its Area2D assigned to this group.
		# This ensures only flame sources can burn the object.

		_burn()
		# Calls the burn function to destroy the object.
