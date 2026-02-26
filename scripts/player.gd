extends CharacterBody2D


const SPEED = 500.0
const ACCELERATION = 10000.0
const DECELERATION = 3500.0

const JUMP_VELOCITY = -1000.0
const JUMP_CUT_MULTIPLIER = 1.1

const FALL_GRAVITY_MULTIPLIER = 3
const LOW_JUMP_GRAVITY_MULTIPLIER = 5
var speedMultiplier := 1.0
var gravityMultiplier := 1.0
enum Mat {STONE, AMBER, LAPIS, EMERALD}
@export var currentMat = Mat.STONE
var heavy = false
var flameOn = false
var flameTime = 3
const flameMax = 3
var burning = false
var cooldown = 0
var onCooldown = false
const cooldownMax = 6
var checkStone = false
var checkLapis = false
var checkEmerald = false
var checkAmber = false
var inLava = false


func _reload_scene():
	get_tree().reload_current_scene()
 
func _color_change():
	if checkStone == true or currentMat == Mat.STONE:
		$Sprite2D.modulate = Color.WHITE
	if checkAmber == true or currentMat == Mat.AMBER:
		$Sprite2D.modulate = Color.ORANGE
	if checkLapis == true or currentMat == Mat.LAPIS:
		$Sprite2D.modulate = Color.BLUE
	if checkEmerald == true or currentMat == Mat.EMERALD:
		$Sprite2D.modulate = Color.GREEN
func _physics_process(delta):
	_color_change()
	if onCooldown:
		cooldown -= delta
		if cooldown <= 0:
			onCooldown = false
			cooldown = 0
			flameTime = flameMax
			
	if flameOn:
		flameTime -= delta
		$Flame/Sprite2Dx.visible = true
		$Flame/CollisionShape2D.disabled = false
	else:
		$Flame/Sprite2Dx.visible = false
		$Flame/CollisionShape2D.disabled = true
	if flameTime <= 0:
		flameOn = false
		speedMultiplier = 1
		gravityMultiplier = 1
		currentMat = Mat.STONE
	if inLava == true:
		if not Mat.AMBER:
			call_deferred("_reload_scene")
	# Handle power upsd
	var gravity = get_gravity()
	if currentMat == Mat.STONE:
		if Input.is_action_just_pressed("power") and not is_on_floor() and not onCooldown:
			onCooldown = true
			cooldown = cooldownMax
			gravityMultiplier = 5.0
			heavy = true
	if currentMat == Mat.AMBER:
		if Input.is_action_just_pressed("power") and not onCooldown:
			onCooldown = true
			cooldown = cooldownMax
			flameOn = true
			speedMultiplier = 0.5
			gravityMultiplier = 0.5
			print("FLAME ON!!!")
			
	if heavy == true and is_on_floor():
		gravityMultiplier = 1.0
		heavy = false
		
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > 0:
			velocity += (gravity * gravityMultiplier) * FALL_GRAVITY_MULTIPLIER * delta
		elif not Input.is_action_pressed("jump"):
			velocity += gravity * LOW_JUMP_GRAVITY_MULTIPLIER * delta
		else:
			velocity += gravity  * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		var targetSpeed = direction * (SPEED * speedMultiplier)
		velocity.x = move_toward(velocity.x,targetSpeed,ACCELERATION  * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION  * delta)
		
	# Handle reseting
	if Input.is_action_just_pressed("reset"):
		call_deferred("_reload_scene")
		
	if Input.is_action_just_pressed("switch"):
		if checkStone == true:
			currentMat = Mat.STONE
			_color_change()
		
		if checkEmerald == true:
			currentMat = Mat.EMERALD
			_color_change()
		
		if checkLapis == true:
			currentMat = Mat.LAPIS
			_color_change()
		
		if checkAmber == true:
			currentMat = Mat.AMBER
			_color_change()
	
	move_and_slide()
	


func _on_mat_check_area_entered(area):
	if area.is_in_group("stone"):
		checkStone = true
	if area.is_in_group("lapis"):
		checkLapis = true
	if area.is_in_group("emerald"):
		checkEmerald = true
	if area.is_in_group("amber"):
		checkAmber = true

func _on_mat_check_area_exited(area):
	if area.is_in_group("stone"):
		checkStone = false
	if area.is_in_group("lapis"):
		checkLapis = false
	if area.is_in_group("emerald"):
		checkEmerald = false
	if area.is_in_group("amber"):
		checkAmber = false
func _ready() -> void:
	_color_change()


func _on_flame_area_entered(area):
	if area.is_in_group("plant"):
		burning = true 
