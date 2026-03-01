extends CharacterBody2D
# This script controls a 2D player character using Godot's CharacterBody2D.
# CharacterBody2D provides built-in physics movement using the velocity variable
# and functions like move_and_slide().
# This player also supports multiple MATERIAL FORMS, each with unique abilities.


# =========================
# MOVEMENT CONSTANTS
# =========================
@export var SPEED = 500.0
# Base horizontal speed before modifiers.

@export var ACCELERATION = 10000.0
# Rate of increasing velocity toward target speed.

@export var DECELERATION = 3500.0
# Rate of slowing down when no input is provided.


# =========================
# JUMP CONSTANTS
# =========================
@export var JUMP_VELOCITY = -1000.0
# Instant upward force applied when jumping.

@export var JUMP_CUT_MULTIPLIER = 1.1
# Reserved variable for scaling upward velocity when jump is released early.
# Currently unused because a direct velocity override is used instead.


# =========================
# GRAVITY MODIFIERS
# =========================
@export var FALL_GRAVITY_MULTIPLIER = 3
# Makes falling feel heavier and faster than rising.
# Improves responsiveness and platformer feel.

@export var LOW_JUMP_GRAVITY_MULTIPLIER = 5
# Makes short hops possible when releasing jump early.


# =========================
# DYNAMIC MODIFIERS (change during gameplay)
# =========================
@export var speedMultiplier := 1.0
# Multiplies final horizontal speed.
# Used by abilities to slow or alter mobility.

@export var gravityMultiplier := 1.0
# Multiplies gravity strength dynamically.
# Used for slam ability or float effects.


# =========================
# MATERIAL ENUM
# =========================
enum Mat {STONE, AMBER, LAPIS, EMERALD}
# Defines material IDs as integers internally:
# STONE   = 0
# AMBER   = 1
# LAPIS   = 2
# EMERALD = 3
# Using enum improves readability and prevents magic numbers.
enum Facing {LEFT, RIGHT}
@export var isFacing = Facing.RIGHT
@export var currentMat = Mat.STONE
# Tracks the currently active material.
# Determines ability behavior, resistances, and visuals.


# =========================
# POWER STATE VARIABLES
# =========================
var heavy = false
# True only during STONE slam ability.
# Used by breakable floors to detect slam impact.

var flameOn = false
# True while AMBER flame ability is active.
# Enables flame collision and visuals.

var flameTime = 3
# Remaining flame duration countdown timer.

const flameMax = 3
# Used to reset flameTime after cooldown ends.


var GrowOn = false
# True while EMERALD growth ability is active.
# Enables growth collision and visuals.

var GrowTime = 3
# Remaining growth ability duration timer.

const GrowMax = 3
# Reserved maximum duration for growth ability reset.


var cooldown = 0
# Remaining cooldown time before next ability use allowed.

var onCooldown = false
# Prevents abilities from being spammed.

const cooldownMax = 6
# Total cooldown duration after using an ability.


# =========================
# MATERIAL DETECTION FLAGS
# =========================
var checkStone = false
# True while overlapping a stone material zone Area2D.

var checkLapis = false
# True while overlapping lapis zone.

var checkEmerald = false
# True while overlapping emerald zone.

var checkAmber = false
# True while overlapping amber zone.


var inLava = false
# True while physically inside lava Area2D.
# Used to determine whether player should die when protection ends.


# =========================
# RELOAD FUNCTION
# =========================
func _reload_scene():
	get_tree().reload_current_scene()
	# Reloads entire scene instantly.
	# Used for death, reset, or failure states.


# =========================
# COLOR CHANGE FUNCTION
# =========================
func _color_change():

	# This function prioritizes ANY detected material OR current material.
	# Because these are separate IF statements (not elif),
	# the LAST matching condition determines final color.

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
	# Ensures material color updates immediately if material changes mid-frame.
	if Input.is_action_pressed("right"): 
		isFacing = Facing.RIGHT
	elif Input.is_action_pressed("left"): 
		isFacing = Facing.LEFT

	$Sprite2D.flip_h = isFacing == Facing.LEFT
	# COOLDOWN TIMER
	# =========================
	if onCooldown:

		cooldown -= delta
		# Countdown happens in real-time seconds.

		if cooldown <= 0:

			onCooldown = false
			# Player can use abilities again.

			cooldown = 0
			# Prevent negative timer values.

			flameTime = flameMax
			# Reset flame duration ready for next use.
			# (Note: GrowTime reset is not here, so growth depends on initial value)


	# =========================
	# FLAME STATE CONTROL
	# =========================
	if flameOn:

		flameTime -= delta
		# Counts down ability duration.

		$Flame/Sprite2Dx.visible = true
		# Enables visual indicator of flame ability.

		$Flame/CollisionShape2D.disabled = false
		# Enables Area2D collision used to burn plants or interact with objects.

	else:

		$Flame/Sprite2Dx.visible = false

		$Flame/CollisionShape2D.disabled = true
		# Prevents unintended burning when flame inactive.


	# =========================
	# GROWTH STATE CONTROL
	# =========================
	if GrowOn:

		GrowTime -= delta
		# Countdown for emerald growth ability.

		$Growth/Sprite2Dx.visible = true
		# Shows growth visual effect.

		$Growth/CollisionShape2D.disabled = false
		# Enables growth interaction collider.

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
		# Player always reverts to default stone state after ability ends.


	if GrowTime <= 0:

		GrowOn = false
		speedMultiplier = 1
		gravityMultiplier = 1
		currentMat = Mat.STONE

		if inLava == true:
			# Important safety mechanic:
			# If player was surviving lava only due to ability,
			# losing ability instantly kills them.
			call_deferred("_reload_scene")


	# =========================
	# POWER-UP ABILITY LOGIC
	# =========================
	var gravity = get_gravity()
	# Retrieves project gravity setting dynamically.
	# Allows global gravity changes without modifying script.


	if currentMat == Mat.STONE:

		if Input.is_action_just_pressed("power") and not is_on_floor() and not onCooldown:

			onCooldown = true
			cooldown = cooldownMax

			gravityMultiplier = 5.0
			# Massive gravity increase creates slam effect.

			heavy = true
			# Used by breakable floors to detect slam state.


	if currentMat == Mat.AMBER:

		if Input.is_action_just_pressed("power") and not onCooldown:

			onCooldown = true
			cooldown = cooldownMax

			flameOn = true

			speedMultiplier = 0.5
			# Slows player to balance offensive ability.

			gravityMultiplier = 0.5
			# Creates floatier movement feeling.

			print("FLAME ON!!!")


	if currentMat == Mat.EMERALD:

		if Input.is_action_just_pressed("power") and not onCooldown:

			onCooldown = true
			cooldown = cooldownMax

			GrowOn = true
			# Enables growth interaction system.

			speedMultiplier = 0.5

			gravityMultiplier = 0.5

			print("GOING GREEN")


	# =========================
	# HEAVY RESET
	# =========================
	if heavy == true and is_on_floor():

		gravityMultiplier = 1.0
		# Restore normal gravity once slam finishes.

		heavy = false
		# Prevents permanent heavy state.


	# =========================
	# GRAVITY APPLICATION
	# =========================
	if not is_on_floor():

		if velocity.y > 0:
			# Falling
			velocity += (gravity * gravityMultiplier) * FALL_GRAVITY_MULTIPLIER * delta

		elif not Input.is_action_pressed("jump"):
			# Jump released early
			velocity += gravity * LOW_JUMP_GRAVITY_MULTIPLIER * delta

		else:
			# Rising normally
			velocity += gravity * delta


	# =========================
	# JUMP INPUT
	# =========================
	if Input.is_action_just_pressed("jump") and is_on_floor():

		velocity.y = JUMP_VELOCITY


	if Input.is_action_just_released("jump") and velocity.y < 0:

		# Immediately cancels upward velocity.
		# This creates sharp, responsive short jumps.
		velocity.y = 1


	# =========================
	# HORIZONTAL MOVEMENT
	# =========================

	var direction := Input.get_axis("left", "right")

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

		# Player switches to whichever material zone they are currently touching.
		# Multiple zones overlapping means last condition wins.

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
	# Applies velocity, handles collisions, sliding, and floor detection.


# =========================
# MATERIAL DETECTION SIGNALS
# =========================
func _on_mat_check_area_entered(area):

	# These detect proximity to material shrines, crystals, or zones.

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
	# Ensures correct visual state immediately when scene loads.
