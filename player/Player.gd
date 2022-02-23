extends KinematicBody2D

export (int) var speed = 200
export (float) var acceleration = 0.5
export (float) var friction = 0.5
export(int) var jump_speed = -200
export(int) var gravity = 800

var velocity = Vector2()
var direction = Vector2.RIGHT

var swinging = false
var swing_duration = 0.8
var swing_power = 0
var max_swing_power = 200

var back_swing = 2.35619

func get_input():
	var mod = 1
	var dir = 0

	if is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity.y += jump_speed

	var old_direction: Vector2 = direction
	if Input.is_action_pressed("walk_right"):
		dir += mod
		direction = Vector2.RIGHT
		
	if Input.is_action_pressed("walk_left"):
		dir -= mod
		direction = Vector2.LEFT

	if dir != 0:
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


func can_hit(ball: Node2D):
	var dir = Vector2(ball.position.x - self.position.x, 0).normalized()
	
	if dir != self.direction:
		return false

	var distance = self.position.distance_to(ball.position)
	if distance > 30:
		return false
		
	if not is_on_floor():
		return false

	return true

func _process(delta):
	if Input.is_action_pressed("swing"):
		var swing_inc = max_swing_power / 1.5
		swing_power = min(swing_power + (swing_inc * delta), max_swing_power)
		print(swing_power)
		
	var club_rot = abs((back_swing / max_swing_power) * swing_power)
	if direction == Vector2.RIGHT:
		$Club.set_rotation(club_rot)
	else:
		$Club.set_rotation(-club_rot)


func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	$AnimatedSprite.flip_h = direction == Vector2.LEFT
	if abs(velocity.x) >= 1:
		$AnimatedSprite.animation = 'walk'
	else:
		$AnimatedSprite.animation = 'idle'
