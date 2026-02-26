extends CharacterBody2D
# This script controls a 2D player character using Godot's CharacterBody2D.
# CharacterBody2D provides built-in physics movement using the velocity variable
# and functions like move_and_slide().


# =========================
# MOVEMENT CONSTANTS
# =========================
const SPEED = 500.0
# The maximum horizontal movement speed of the player (pixels per second).

const ACCELERATION = 10000.0
# How quickly the player reaches the target speed when pressing left/right.
# Higher value = reaches full speed faster.

const DECELERATION = 3500.0
# How quickly the player slows down when no movement key is pressed.


# =========================
# JUMP CONSTANTS
# =========================
const JUMP_VELOCITY = -1000.0
# The upward velocity applied when jumping.
# Negative because in Godot, upward movement is negative Y.

const JUMP_CUT_MULTIPLIER = 1.1
# Intended to shorten jump height if the jump button is released early.
# (Currently not used because that line is commented out later.)


# =========================
# GRAVITY MODIFIERS
# =========================
const FALL_GRAVITY_MULTIPLIER = 3
# Multiplies gravity when falling downward to make falls faster/snappier.

const LOW_JUMP_GRAVITY_MULTIPLIER = 5
# Multiplies gravity when jump is released early, creating shorter jumps.


# =========================
# DYNAMIC MODIFIERS (change during gameplay)
# =========================
var speedMultiplier := 1.0
# Multiplies horizontal speed. Used by power-ups to slow or boost movement.

var gravityMultiplier := 1.0
# Multiplies gravity strength. Used by heavy mode or power-ups.


# =========================
# MATERIAL ENUM
# =========================
enum Mat {STONE, AMBER, LAPIS, EMERALD}
# Creates a list of named constants representing player material types.
# These act like different "forms" with unique abilities.


@export var currentMat = Mat.STONE
# The player's current material.
# @export allows you to change it from the Godot editor.


# =========================
# POWER STATE VARIABLES
# =========================
var heavy = false
# True when the player is in heavy mode (STONE ability).
# Heavy mode increases gravity to slam downward faster.

var flameOn = false
# True when AMBER flame ability is active.

var flameTime = 3
# Remaining time for flame ability (seconds).

const flameMax = 3
# Maximum flame duration (used to reset flameTime).

var burning = false
# True when flame touches something burnable (like plants).

var cooldown = 0
# Current cooldown timer remaining.

var onCooldown = false
# True when abilities cannot be used.

const cooldownMax = 6
# Maximum cooldown duration (seconds).


# =========================
# MATERIAL DETECTION FLAGS
# =========================
var checkStone = false
# True when player is touching a stone material zone.

var checkLapis = false
# True when player is touching a lapis material zone.

var checkEmerald = false
# True when player is touching an emerald material zone.

var checkAmber = false
# True when player is touching an amber material zone.


var inLava = false
# True if the player is inside lava.
# Used to kill the player unless protected by flame.


# =========================
# RELOAD FUNCTION
# =========================
func _reload_scene():
	get_tree().reload_current_scene()
	# Reloads the current level.
	# Used for death or manual reset.


# =========================
# COLOR CHANGE FUNCTION
# =========================
func _color_change():
	# Changes the player's sprite color depending on current material
	# or detected nearby material.

	if checkStone == true or currentMat == Mat.STONE:
		$Sprite2D.modulate = Color.WHITE
		# Stone material = white color.

	if checkAmber == true or currentMat == Mat.AMBER:
		$Sprite2D.modulate = Color.ORANGE
		# Amber material = orange color.

	if checkLapis == true or currentMat == Mat.LAPIS:
		$Sprite2D.modulate = Color.BLUE
		# Lapis material = blue color.

	if checkEmerald == true or currentMat == Mat.EMERALD:
		$Sprite2D.modulate = Color.GREEN
		# Emerald material = green color.


# =========================
# MAIN PHYSICS LOOP
# Runs every physics frame (~60 times per second)
# =========================
func _physics_process(delta):

	_color_change()
	# Always update sprite color based on material.


	# =========================
	# COOLDOWN TIMER
	# =========================
	if onCooldown:
		cooldown -= delta
		# Reduce cooldown timer over time.

		if cooldown <= 0:
			onCooldown = false
			cooldown = 0
			flameTime = flameMax
			# When cooldown ends, allow abilities again
			# and reset flame duration.


	# =========================
	# FLAME STATE CONTROL
	# =========================
	if flameOn:
		flameTime -= delta
		# Reduce flame duration.

		$Flame/Sprite2Dx.visible = true
		# Show flame visual effect.

		$Flame/CollisionShape2D.disabled = false
		# Enable flame collision so it can burn objects.

	else:
		$Flame/Sprite2Dx.visible = false
		# Hide flame visuals.

		$Flame/CollisionShape2D.disabled = true
		# Disable flame collision.


	if flameTime <= 0:
		# Flame expired.

		flameOn = false
		speedMultiplier = 1
		gravityMultiplier = 1
		currentMat = Mat.STONE
		# Reset player to default stone state.

		if inLava == true:
			call_deferred("_reload_scene")
			# If in lava without flame protection, reload scene (player dies).


	# =========================
	# POWER-UP ABILITY LOGIC
	# =========================
	var gravity = get_gravity()
	# Gets the default gravity value from project settings.


	if currentMat == Mat.STONE:
		# Stone ability = heavy slam

		if Input.is_action_just_pressed("power") and not is_on_floor() and not onCooldown:
			onCooldown = true
			cooldown = cooldownMax
			gravityMultiplier = 5.0
			# Increase gravity massively to fall faster.

			heavy = true
			# Mark heavy mode active.


	if currentMat == Mat.AMBER:
		# Amber ability = flame mode

		if Input.is_action_just_pressed("power") and not onCooldown:
			onCooldown = true
			cooldown = cooldownMax

			flameOn = true
			# Activate flame ability.

			speedMultiplier = 0.5
			# Reduce speed while flaming.

			gravityMultiplier = 0.5
			# Reduce gravity for floaty feel.

			print("FLAME ON!!!")
			# Debug message.


	# Reset heavy mode when landing
	if heavy == true and is_on_floor():
		gravityMultiplier = 1.0
		heavy = false


	# =========================
	# GRAVITY APPLICATION
	# =========================
	if not is_on_floor():

		if velocity.y > 0:
			# Falling downward
			velocity += (gravity * gravityMultiplier) * FALL_GRAVITY_MULTIPLIER * delta

		elif not Input.is_action_pressed("jump"):
			# Jump released early (short hop)
			velocity += gravity * LOW_JUMP_GRAVITY_MULTIPLIER * delta

		else:
			# Normal upward movement
			velocity += gravity * delta


	# =========================
	# JUMP INPUT
	# =========================
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# Apply upward force.


	if Input.is_action_just_released("jump") and velocity.y < 0:
		# Stops upward motion quickly when jump released.
		# This creates variable jump height.

		#velocity.y *= JUMP_CUT_MULTIPLIER
		velocity.y = 1


	# =========================
	# HORIZONTAL MOVEMENT
	# =========================
	var direction := Input.get_axis("left", "right")
	# Returns:
	# -1 if pressing left
	# +1 if pressing right
	# 0 if neither


	if direction != 0:

		var targetSpeed = direction * (SPEED * speedMultiplier)
		# Calculate desired speed based on input and modifiers.

		velocity.x = move_toward(
			velocity.x,
			targetSpeed,
			ACCELERATION * delta
		)
		# Smoothly accelerate toward target speed.

	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			DECELERATION * delta
		)
		# Smoothly slow to stop.


	# =========================
	# RESET INPUT
	# =========================
	if Input.is_action_just_pressed("reset"):
		call_deferred("_reload_scene")
		# Reload scene manually.


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
		# Switch to whichever material zone the player is touching.


	# =========================
	# FINAL MOVEMENT EXECUTION
	# =========================
	move_and_slide()
	# Moves the character using velocity and handles collisions automatically.



# =========================
# MATERIAL DETECTION SIGNALS
# =========================
func _on_mat_check_area_entered(area):

	if area.is_in_group("stone"):
		checkStone = true
		# Player entered stone material area.

	if area.is_in_group("lapis"):
		checkLapis = true

	if area.is_in_group("emerald"):
		checkEmerald = true

	if area.is_in_group("amber"):
		checkAmber = true


func _on_mat_check_area_exited(area):

	if area.is_in_group("stone"):
		checkStone = false
		# Player left stone area.

	if area.is_in_group("lapis"):
		checkLapis = false

	if area.is_in_group("emerald"):
		checkEmerald = false

	if area.is_in_group("amber"):
		checkAmber = false


# =========================
# READY FUNCTION
# Runs once when node enters scene
# =========================
func _ready() -> void:
	_color_change()
	# Ensures correct color at game start.


# =========================
# FLAME COLLISION SIGNAL
# =========================
func _on_flame_area_entered(area):

	if area.is_in_group("plant"):
		burning = true
		# Marks plant as burning when flame touches it.
