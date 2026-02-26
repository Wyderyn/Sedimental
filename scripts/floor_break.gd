extends StaticBody2D
@export var breakVelocity := 800.0

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var broken = false
func _breakfloor():
	broken = true
	
	collider.set_deferred("disabled", true)
	
	sprite.set_deferred("visible", false)
	
	$Area2D.set_deferred("monitoring", false)

func _on_area_2d_body_entered(body):
	if broken:
		print("already broken")
		return
	
	if not body.is_in_group("player"):
		print("this is not the player")
		return
	
	if not body.heavy:
		print("the player is't heavy enough")
		return
	
	if body.velocity.y > breakVelocity:
		print("player is not fast enough")
		return
	
	_breakfloor()
	
