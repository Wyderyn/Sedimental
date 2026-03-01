extends CharacterBody2D
# This script controls the player character using Godot's CharacterBody2D.
# CharacterBody2D is designed for platformer-style movement and includes:
# • A built-in velocity variable (Vector2) that stores current motion
# • move_and_slide() for automatic collision handling
# • Floor detection via is_on_floor()
# This character can transform into different MATERIAL FORMS,
# each granting unique physics and abilities.


# =========================
# MOVEMENT CONSTANTS
# =========================
@export var SPEED = 500.0
# Maximum horizontal movement speed before modifiers.
# Final speed calculation:
# velocity.x target = input_direction * SPEED * speedMultiplier
# speedMultiplier allows abilities to slow or boost the player.

@export var ACCELERATION = 10000.0
# Controls how quickly the player reaches target speed.
# High value = instant, responsive movement.
# Low value = slippery, momentum-based movement.

@export var DECELERATION = 3500.0
# Controls how quickly the player slows when no input is pressed.
# Prevents infinite sliding.


var canJump = true
# Determines whether the player is currently allowed to jump.
# This is controlled by the coyote time system below.
# TRUE = jump allowed
# FALSE = jump blocked


# =========================
# JUMP CONSTANTS
# =========================
@export var JUMP_VELOCITY = -1000.0
# Instant upward force applied when jumping.
# Negative because Godot's Y axis increases downward.

@export var JUMP_CUT_MULTIPLIER = 1.1
# Reserved for advanced jump shaping.
# Currently unused because jump cutting directly sets velocity.

@export var cyoteTime = .5
# Countdown timer that allows jumping AFTER leaving a platform.
# This creates "coyote time", making jumps feel more forgiving.
# Measured in physics frames (not seconds).

@export var cyote = .5
# Stores the MAXIMUM coyote time value.
# Used to reset cyoteTime when player touches the ground.


# =========================
# GRAVITY MODIFIERS
# =========================
@export var FALL_GRAVITY_MULTIPLIER = 3
# Makes falling faster than rising.
# Improves responsiveness and makes jumps feel less floaty.

@export var LOW_JUMP_GRAVITY_MULTIPLIER = 5
# Makes player fall faster when jump is released early.
# This allows short hops.


# =========================
# DYNAMIC MODIFIERS (change during gameplay)
# =========================
@export var speedMultiplier := 1.0
# Multiplies horizontal speed dynamically.
# Used by abilities to balance power vs mobility.

@export var gravityMultiplier := 1.0
# Multiplies gravity dynamically.
# Used by slam ability or float abilities.


# =========================
# MATERIAL ENUM
# =========================
enum Mat {STONE, AMBER, LAPIS, EMERALD}
# Enum automatically assigns integer IDs:
# STONE   = 0
# AMBER   = 1
# LAPIS   = 2
# EMERALD = 3

enum Facing {LEFT, RIGHT}
# Used to control sprite orientation.

@export var isFacing = Facing.RIGHT
# Default starting direction.

@export var currentMat = Mat.STONE
# Determines which ability is active.


# =========================
# POWER STATE VARIABLES
# =========================
var heavy = false
# TRUE only during STONE slam.
# Breakable floors check this variable.

var flameOn = false
# TRUE while flame ability is active.

var flameTime = 3
# Remaining flame duration in seconds.

const flameMax = 3
# Used to reset flame duration.


var GrowOn = false
# TRUE while emerald growth ability active.

var GrowTime = 3
# Remaining growth duration.

const GrowMax = 3
# Maximum growth duration.


var cooldown = 0
# Remaining cooldown time in seconds.

var onCooldown = false
# Prevents ability spam.

const cooldownMax = 6
# Maximum cooldown duration.


# =========================
# MATERIAL DETECTION FLAGS
# =========================
var checkStone = false
var checkLapis = false
var checkEmerald = false
var checkAmber = false
# These track whether player is touching material zones.
# Used to allow switching materials.

var inLava = false
# TRUE when inside lava hazard.
# Used to kill player if protection ends.


# =========================
# RELOAD FUNCTION
# =========================
func _reload_scene():
	get_tree().reload_current_scene()
	# Reloads entire level.
	# This resets player, objects, and variables.


# =========================
# COLOR CHANGE FUNCTION
# =========================
func _color_change():

	# Updates sprite texture based on material or nearby zone.
	# Multiple IF statements means later ones override earlier ones.

	if checkStone == true or currentMat == Mat.STONE:
		$Sprite2D.texture = load("res://sprites/Player/Geo(Stone) (1).png")

	if checkAmber == true or currentMat == Mat.AMBER:
		$Sprite2D.texture = load("res://sprites/Player/Geo(Amber) (1).png")

	if checkLapis == true or currentMat == Mat.LAPIS:
		$Sprite2D.texture = load("res://sprites/Player/Geo(Lapis) (1).png")

	if checkEmerald == true or currentMat == Mat.EMERALD:
		$Sprite2D.texture = load("res://sprites/Player/Geo(Emerald) (1).png")


# =========================
# MAIN PHYSICS LOOP
# =========================
func _physics_process(delta):

	_color_change()
	# Keeps sprite and jump permissions updated.

	# =========================
	# COYOTE TIME SYSTEM
	# =========================
	if is_on_floor():
		canJump = true
		# Player can always jump when touching floor.

		cyoteTime = cyote
		# Reset coyote timer to maximum value.


	if not is_on_floor():
		cyoteTime -= delta
		# Each physics frame in air reduces timer.

	if canJump:
		if cyoteTime <= 0:
			canJump = false
			# Once timer expires, jumping is disabled.
			# This prevents infinite air jumps.



	if Input.is_action_pressed("right"): 
		isFacing = Facing.RIGHT

	elif Input.is_action_pressed("left"): 
		isFacing = Facing.LEFT


	$Sprite2D.flip_h = isFacing == Facing.LEFT
	# Flips sprite horizontally.


	# =========================
	# COOLDOWN TIMER
	# =========================
	if onCooldown:

		cooldown -= delta
		# delta = seconds since last frame.

		if cooldown <= 0:

			onCooldown = false
			cooldown = 0

			flameTime = flameMax
			# Reset flame duration.


	# =========================
	# FLAME STATE
	# =========================
	if flameOn:

		flameTime -= delta

		$Flame/Sprite2Dx.visible = true
		# Shows flame visual.

		$Flame/CollisionShape2D.disabled = false
		# Enables burn hitbox.

	else:

		$Flame/Sprite2Dx.visible = false
		$Flame/CollisionShape2D.disabled = true


	# =========================
	# GROWTH STATE
	# =========================
	if GrowOn:

		GrowTime -= delta

		$Growth/Sprite2Dx.visible = true
		$Growth/CollisionShape2D.disabled = false

	else:

		$Growth/Sprite2Dx.visible = false
		$Growth/CollisionShape2D.disabled = true


	# =========================
	# ABILITY EXPIRATION
	# =========================
	if flameTime <= 0:

		flameOn = false
		speedMultiplier = 1
		gravityMultiplier = 1
		currentMat = Mat.STONE

		if inLava:
			_reload_scene()
		# Player dies if lava protection ends.


	if GrowTime <= 0:

		GrowOn = false
		speedMultiplier = 1
		gravityMultiplier = 1
		currentMat = Mat.STONE

		if inLava == true:
			call_deferred("_reload_scene")


	# =========================
	# ABILITY ACTIVATION
	# =========================
	var gravity = get_gravity()
	# Retrieves global gravity value.


	if currentMat == Mat.STONE:

		if Input.is_action_just_pressed("power") and not is_on_floor() and not onCooldown:

			onCooldown = true
			cooldown = cooldownMax

			gravityMultiplier = 5.0
			# Forces fast downward slam.

			heavy = true
			# Breakable floors detect this.


	if currentMat == Mat.AMBER:

		if Input.is_action_just_pressed("power") and not onCooldown:

			onCooldown = true
			cooldown = cooldownMax

			flameOn = true
			speedMultiplier = 0.5
			gravityMultiplier = 0.5

			print("FLAME ON!!!")


	if currentMat == Mat.EMERALD:

		if Input.is_action_just_pressed("power") and not onCooldown:

			onCooldown = true
			cooldown = cooldownMax

			GrowOn = true
			speedMultiplier = 0.5
			gravityMultiplier = 0.5

			print("GOING GREEN")


	# =========================
	# SLAM RESET
	# =========================
	if heavy == true and is_on_floor():

		gravityMultiplier = 1.0
		heavy = false
		# Slam ends upon landing.


	# =========================
	# GRAVITY APPLICATION
	# =========================
	if not is_on_floor():

		if velocity.y > 0:
			# Falling downward
			velocity += (gravity * gravityMultiplier) * FALL_GRAVITY_MULTIPLIER * delta

		elif not Input.is_action_pressed("jump"):
			# Jump released early
			velocity += gravity * LOW_JUMP_GRAVITY_MULTIPLIER * delta

		else:
			# Normal upward movement
			velocity += gravity * delta


	# =========================
	# JUMP INPUT
	# =========================
	if Input.is_action_just_pressed("jump") and canJump:

		velocity.y = JUMP_VELOCITY
		# Instant upward movement.
		canJump = false


	if Input.is_action_just_released("jump") and velocity.y < 0:

		velocity.y = 1
		# Cuts jump height immediately.


	# =========================
	# HORIZONTAL MOVEMENT
	# =========================
	var direction := Input.get_axis("left", "right")
	# Returns value between −1 and +1

	if direction != 0:

		var targetSpeed = direction * (SPEED * speedMultiplier)

		velocity.x = move_toward(
			velocity.x,
			targetSpeed,
			ACCELERATION * delta
		)

	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			DECELERATION * delta
		)


	# =========================
	# RESET INPUT
	# =========================
	if Input.is_action_just_pressed("reset"):

		call_deferred("_reload_scene")


	# =========================
	# MATERIAL SWITCH INPUT
	# =========================
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


	# =========================
	# FINAL MOVEMENT
	# =========================
	move_and_slide()
	# Applies velocity
	# Resolves collisions
	# Updates floor detection


# =========================
# MATERIAL DETECTION SIGNALS
# =========================
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


# =========================
# READY FUNCTION
# =========================
func _ready() -> void:

	_color_change()
	# Ensures correct sprite immediately when level loads.
