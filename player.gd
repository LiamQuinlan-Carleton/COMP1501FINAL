extends CharacterBody2D

@export var jump_speed : float
@export var jump_length : float
@export var jump_end_force : float

var is_jumping : bool

@export var jump_timer : Timer

@export var speed : float

var direction : int = 1

@export var gravity : float

@export var friction : float

func _process(delta: float) -> void:
	
	velocity.y += gravity
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		is_jumping = true
		jump_timer.start(jump_length)
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
		velocity.x -= direction * friction * delta
	else:
		velocity.x = 0
	
	move_and_slide()

func _on_jump_length_timeout() -> void:
	is_jumping = false


func _on_jump_buffer_timeout() -> void:
	pass # Replace with function body.
