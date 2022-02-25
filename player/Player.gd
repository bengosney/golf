extends KinematicBody2D

const NO_MOVE_FOR = 0.05

export(int) var speed = 200
export(float) var acceleration = 0.5
export(float) var friction = 0.5
export(int) var jump_speed = -200
export(int) var gravity = 800

var velocity = Vector2()
var direction = Vector2.RIGHT

var swinging = false
var swing_duration = 0.8
var swing_power = 0
var max_swing_power = 200

var back_swing = 2.35619

var jumps = 1
var max_jumps = 2

var no_move = 0

onready var extents = get_extents()


func get_input(delta):
	var mod = 1
	var dir = 0

	if Input.is_action_just_released("walk_left") or Input.is_action_just_released("walk_right"):
		no_move = 0

	no_move = max(no_move - delta, 0)
	var changed_direction = no_move > 0

	if Input.is_action_just_pressed("walk_left") and direction == Vector2.RIGHT:
		changed_direction = true
		no_move = NO_MOVE_FOR
	if Input.is_action_just_pressed("walk_right") and direction == Vector2.LEFT:
		changed_direction = true
		no_move = NO_MOVE_FOR

	if is_on_floor():
		jumps = 1

	if is_on_floor() or jumps < 2:
		if Input.is_action_just_pressed("jump"):
			velocity.y = min(max_jumps, velocity.y + (jump_speed * jumps))
			jumps += 0.5

	if Input.is_action_pressed("walk_right"):
		dir += mod
		direction = Vector2.RIGHT

	if Input.is_action_pressed("walk_left"):
		dir -= mod
		direction = Vector2.LEFT

	if dir != 0 and not changed_direction:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)

	if Input.is_action_just_released("swing"):
		print("swing")
		#swinging = true
		for ball in get_tree().get_nodes_in_group("ball"):
			if can_hit(ball):
				var hit_direction = (direction + Vector2.UP) * swing_power
				print(hit_direction)
				ball.apply_central_impulse(hit_direction)

		swing_power = 0


func get_extents():
	var min_vec = Vector2.INF
	var max_vec = Vector2.ZERO

	for vec in $CollisionPolygon2D.polygon:
		min_vec.x = min(min_vec.x, vec.x)
		min_vec.y = min(min_vec.y, vec.y)

		max_vec.x = max(max_vec.x, vec.x)
		max_vec.y = max(max_vec.y, vec.y)

	return [min_vec, max_vec]


func can_hit(ball: Node2D):
	var dir = Vector2(ball.position.x - self.position.x, 0).normalized()
	var player_width = abs(extents[0].x) + abs(extents[1].x)

	var distance = self.position.distance_to(ball.position)

	if dir != self.direction and distance > (player_width * 0.5):
		return false

	if distance > (player_width * 1.25):
		return false

	if not is_on_floor():
		return false

	return true


func _process(delta):
	if Input.is_action_pressed("swing"):
		var swing_inc = max_swing_power / 1.5
		swing_power = min(swing_power + (swing_inc * delta), max_swing_power)

	var club_rot = abs((back_swing / max_swing_power) * swing_power)
	if direction == Vector2.RIGHT:
		$Club.set_rotation(club_rot)
	else:
		$Club.set_rotation(-club_rot)


func _physics_process(delta):
	get_input(delta)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	$AnimatedSprite.flip_h = direction == Vector2.LEFT
	if abs(velocity.x) >= 1:
		$AnimatedSprite.animation = "walk"
	else:
		$AnimatedSprite.animation = "idle"
