extends StaticBody2D
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var burnt = false
# Called when the node enters the scene tree for the first time.
func _burn():
	if burnt == false:
		burnt = true
		collider.set_deferred("disabled", true)
		sprite.set_deferred("visible", false)
	else:
		return

func _on_area_2d_area_entered(area):
	if area.is_in_group("amber"):
		_burn()
