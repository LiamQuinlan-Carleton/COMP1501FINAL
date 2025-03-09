extends CharacterBody2D

@export var jump_speed : float
@export var jump_length : float
@export var jump_end_force : float
@export var jump_buffer : float

var is_jumping : bool
var can_jump : bool

@export var jump_timer : Timer
@export var jump_buffer_timer : Timer
@export var wall_jump_timer: Timer
@export var speed : float

var direction : int = 1

@export var gravity : float

@export var friction : float
@export var wind_resistance : float

signal is_crouching
func _process(delta: float) -> void:
	#$Speed.text = str(speed)
	velocity.y += gravity
	
	if Input.is_action_just_pressed("Jump"):
		can_jump = true
		jump_buffer_timer.start(jump_buffer)
	# Normal Jumping
	if (Input.is_action_just_pressed("Jump") or can_jump) and is_on_floor():
		is_jumping = true
		can_jump = false
		jump_timer.start(jump_length)
	# Wall Jumping
	if (Input.is_action_just_pressed("Jump") or can_jump) and is_on_wall():
		is_jumping = true
		can_jump = false
		jump_timer.start(jump_length)
		direction = -1*direction
		wall_jump_timer.start()
		speed = 200
	
	if Input.is_action_just_released("Jump"):
		is_jumping = false
		if velocity.y < 0:
			velocity.y += jump_end_force
	
	if is_jumping:
		velocity.y = -jump_speed
	
	if Input.is_action_just_pressed("Right"):
		direction = 1
	if Input.is_action_just_pressed("Left"):
		direction = -1
	if Input.is_action_pressed("Right") or Input.is_action_pressed("Left"):
		velocity.x = speed * direction
	elif velocity.x < -friction * delta or velocity.x > friction * delta:
		if is_on_floor():
			velocity.x -= direction * friction * delta
		else:
			velocity.x -= direction * delta * wind_resistance
	else:
		velocity.x = 0
	if Input.is_action_pressed("Crouch") and is_on_floor():
		emit_signal("is_crouching")
		speed = 550
	if Input.is_action_just_released("Crouch"):
		speed = 400
	move_and_slide()


func _on_jump_length_timeout() -> void:
	is_jumping = false
	speed = 400

func _on_jump_buffer_timeout() -> void:
	can_jump = false


func _on_button_pressed() -> void:
	global_position = Vector2(550,330)


#func _on_wall_jump_timer_timeout() -> void:
	#direction = -1*direction
