extends CharacterBody2D
# This script controls the player character using Godot's CharacterBody2D.
# CharacterBody2D is designed for platformer-style movement and includes:
# • A built-in velocity variable (Vector2)
# • move_and_slide() for collision-aware movement
# • Floor detection (is_on_floor)
# This character can transform into different MATERIAL FORMS,
# each granting unique physics and abilities.


# =========================
# MOVEMENT CONSTANTS
# =========================
@export var SPEED = 500.0
# Maximum horizontal movement speed before modifiers.
# Final speed = SPEED * speedMultiplier

@export var ACCELERATION = 10000.0
# How fast velocity.x moves toward the target speed.
# Higher values = more responsive movement.

@export var DECELERATION = 3500.0
# How fast velocity.x returns to 0 when no input is pressed.
# Controls sliding vs tight movement feel.

var canJump = true
# =========================
# JUMP CONSTANTS
# =========================
@export var JUMP_VELOCITY = -1000.0
# Instant vertical velocity applied when jumping.
# Negative value because upward direction in Godot is negative Y.

@export var JUMP_CUT_MULTIPLIER = 1.1
# Reserved variable for advanced jump control.
# Currently not used because jump cutting is handled manually.

@export var cyoteTime = 50
@export var cyote= 50
# =========================
# GRAVITY MODIFIERS
# =========================
@export var FALL_GRAVITY_MULTIPLIER = 3
# Multiplies gravity while falling downward.
# Makes falling faster than rising for better platformer feel.

@export var LOW_JUMP_GRAVITY_MULTIPLIER = 5
# Multiplies gravity when jump button is released early.
# Allows short, controlled jumps instead of always full height.


# =========================
# DYNAMIC MODIFIERS (change during gameplay)
# =========================
@export var speedMultiplier := 1.0
# Multiplies horizontal speed dynamically.
# Example:
# 1.0 = normal speed
# 0.5 = half speed
# 2.0 = double speed

@export var gravityMultiplier := 1.0
# Multiplies gravity dynamically.
# Used for slam ability (increase gravity)
# and float abilities (reduce gravity)


# =========================
# MATERIAL ENUM
# =========================
enum Mat {STONE, AMBER, LAPIS, EMERALD}
# Enum assigns integer IDs automatically:
# STONE   = 0
# AMBER   = 1
# LAPIS   = 2
# EMERALD = 3
# Using enum avoids confusing "magic numbers"
# and makes code readable.

enum Facing {LEFT, RIGHT}
# Tracks which direction the player is facing visually.

@export var isFacing = Facing.RIGHT
# Default facing direction when game starts.

@export var currentMat = Mat.STONE
# Player starts in STONE form by default.
# This determines which abilities are available.


# =========================
# POWER STATE VARIABLES
# =========================
var heavy = false
# TRUE only during STONE slam ability.
# Breakable floors check this variable to know
# whether player impact should destroy them.

var flameOn = false
# TRUE while flame ability is active.
# Enables flame collision and visuals.

var flameTime = 3
# Remaining seconds before flame ability ends.

const flameMax = 3
# Used to reset flameTime after cooldown.


var GrowOn = false
# TRUE while emerald growth ability is active.

var GrowTime = 3
# Remaining seconds of growth ability.

const GrowMax = 3
# Maximum growth ability duration.


var cooldown = 0
# Countdown timer until ability can be used again.

var onCooldown = false
# Prevents player from activating abilities repeatedly.

const cooldownMax = 6
# Total cooldown duration after ability use.


# =========================
# MATERIAL DETECTION FLAGS
# =========================
var checkStone = false
# TRUE while player is touching a stone material zone.

var checkLapis = false
# TRUE while touching lapis zone.

var checkEmerald = false
# TRUE while touching emerald zone.

var checkAmber = false
# TRUE while touching amber zone.


var inLava = false
# TRUE if player is inside lava area.
# Used to determine death conditions.


# =========================
# RELOAD FUNCTION
# =========================
func _reload_scene():
	get_tree().reload_current_scene()
	# Completely reloads the current level scene.
	# This resets player position, objects, and all variables.


# =========================
# COLOR CHANGE FUNCTION
# =========================
func _color_change():

	# This updates the player sprite based on material.
	# Because these are separate IF statements,
	# the LAST true condition determines final texture.

	if checkStone == true or currentMat == Mat.STONE:
		# If player is stone OR touching stone zone
		$Sprite2D.texture = load("res://sprites/Player/Geo(Stone) (1).png")

	if checkAmber == true or currentMat == Mat.AMBER:
		# Amber form texture
		$Sprite2D.texture = load("res://sprites/Player/Geo(Amber) (1).png")

	if checkLapis == true or currentMat == Mat.LAPIS:
		# Lapis form texture
		$Sprite2D.texture = load("res://sprites/Player/Geo(Lapis) (1).png")

	if checkEmerald == true or currentMat == Mat.EMERALD:
		# Emerald form texture
		$Sprite2D.texture = load("res://sprites/Player/Geo(Emerald) (1).png")
	if is_on_floor():
		canJump = true
		cyoteTime = cyote
	if not is_on_floor():
		cyoteTime -= 1
	if cyoteTime <= 0:
		canJump = false
# =========================
# MAIN PHYSICS LOOP
# =========================
func _physics_process(delta):

	_color_change()
	# Ensures visual sprite always matches current material.

	if Input.is_action_pressed("right"): 
		isFacing = Facing.RIGHT
		# Update facing direction based on input

	elif Input.is_action_pressed("left"): 
		isFacing = Facing.LEFT


	$Sprite2D.flip_h = isFacing == Facing.LEFT
	# Flips sprite horizontally when facing left.
	# This avoids needing separate left/right sprites.


	# =========================
	# COOLDOWN TIMER
	# =========================
	if onCooldown:

		cooldown -= delta
		# delta = time since last frame in seconds
		# This creates real-time countdown.

		if cooldown <= 0:

			onCooldown = false
			# Ability can now be used again.

			cooldown = 0
			# Prevent negative values.

			flameTime = flameMax
			# Reset flame ability timer.


	# =========================
	# FLAME STATE CONTROL
	# =========================
	if flameOn:

		flameTime -= delta
		# Reduce ability duration timer.

		$Flame/Sprite2Dx.visible = true
		# Show flame visual.

		$Flame/CollisionShape2D.disabled = false
		# Enable hitbox that burns plants.

	else:

		$Flame/Sprite2Dx.visible = false
		# Hide flame visual.

		$Flame/CollisionShape2D.disabled = true
		# Disable burn collision.


	# =========================
	# GROWTH STATE CONTROL
	# =========================
	if GrowOn:

		GrowTime -= delta

		$Growth/Sprite2Dx.visible = true
		# Show growth visual effect.

		$Growth/CollisionShape2D.disabled = false
		# Enable growth interaction.

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
		# Reset player completely to default state.


	if GrowTime <= 0:

		GrowOn = false
		speedMultiplier = 1
		gravityMultiplier = 1
		currentMat = Mat.STONE

		if inLava == true:
			# If emerald protection ends while in lava,
			# player dies instantly.
			call_deferred("_reload_scene")


	# =========================
	# POWER-UP ABILITY LOGIC
	# =========================
	var gravity = get_gravity()
	# Gets project gravity from physics settings.


	if currentMat == Mat.STONE:

		if Input.is_action_just_pressed("power") and not is_on_floor() and not onCooldown:

			onCooldown = true
			cooldown = cooldownMax

			gravityMultiplier = 5.0
			# Increase gravity massively
			# Forces player downward quickly.

			heavy = true
			# Signals breakable floors.


	if currentMat == Mat.AMBER:

		if Input.is_action_just_pressed("power") and not onCooldown:

			onCooldown = true
			cooldown = cooldownMax

			flameOn = true
			# Activate flame ability.

			speedMultiplier = 0.5
			# Reduce speed for balance.

			gravityMultiplier = 0.5
			# Makes player float slightly.

			print("FLAME ON!!!")


	if currentMat == Mat.EMERALD:

		if Input.is_action_just_pressed("power") and not onCooldown:

			onCooldown = true
			cooldown = cooldownMax

			GrowOn = true
			# Activate growth ability.

			speedMultiplier = 0.5

			gravityMultiplier = 0.5

			print("GOING GREEN")


	# =========================
	# HEAVY RESET
	# =========================
	if heavy == true and is_on_floor():

		gravityMultiplier = 1.0
		# Restore normal gravity.

		heavy = false
		# Slam finished.


	# =========================
	# GRAVITY APPLICATION
	# =========================
	if not is_on_floor():

		if velocity.y > 0:
			# Player is falling downward
			velocity += (gravity * gravityMultiplier) * FALL_GRAVITY_MULTIPLIER * delta

		elif not Input.is_action_pressed("jump"):
			# Jump button released early
			velocity += gravity * LOW_JUMP_GRAVITY_MULTIPLIER * delta

		else:
			# Normal upward motion
			velocity += gravity * delta


	# =========================
	# JUMP INPUT
	# =========================
	if Input.is_action_just_pressed("jump") and canJump:

		velocity.y = JUMP_VELOCITY
		# Apply instant upward force.


	if Input.is_action_just_released("jump") and velocity.y < 0:

		velocity.y = 1
		# Cuts jump height instantly.


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
		# Smooth acceleration.

	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			DECELERATION * delta
		)
		# Smooth stop.


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
	# FINAL PHYSICS MOVE
	# =========================
	move_and_slide()
	# Moves character using velocity
	# Handles collision automatically
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
	# Ensures correct sprite appears immediately when scene starts.
