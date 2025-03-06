extends CharacterBody2D

@export var jump_speed : float
@export var jump_length : float
@export var jump_end_force : float
@export var jump_buffer : float

var is_jumping : bool
var can_jump : bool

@export var jump_timer : Timer
@export var jump_buffer_timer : Timer

@export var speed : float

var direction : int = 1

@export var gravity : float

@export var friction : float

func _process(delta: float) -> void:
	
	velocity.y += gravity
	
	if Input.is_action_just_pressed("Jump"):
		can_jump = true
		jump_buffer_timer.start(jump_buffer)
	
	if (Input.is_action_just_pressed("Jump") or can_jump) and is_on_floor():
		is_jumping = true
		can_jump = false
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
		if is_on_floor:
			velocity.x -= direction * friction * delta
		else:
			velocity.x -= direction * delta
	else:
		velocity.x = 0
	
	move_and_slide()


func _on_jump_length_timeout() -> void:
	is_jumping = false

func _on_jump_buffer_timeout() -> void:
	can_jump = false


func _on_button_pressed() -> void:
	global_position = Vector2(550,330)
