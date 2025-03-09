extends CharacterBody2D

#Movement "Feel" Variables

#Jump
@export var jump_speed : float
@export var jump_length : float #Time spent moving upwards at jump_speed
@export var jump_end_force : float #Applied when jump button released before peak of jump
@export var jump_buffer : float #Earliest time jump button can be pressed and still allow jump when reaches floor

#Run
@export var speed : float
@export var acceleration : float
@export var floor_friction : float

#Misc
@export var gravity : float

#Timer Nodes
@export var jump_timer : Timer
@export var jump_buffer_timer : Timer
#@export var cyote_time_timer : Timer

#Velocity is done this way to allow the player to move faster than their max run speed using other sources
#var move_velocity : Vector2 #Velocity from player movements (run, jump, etc.)
#var bonus_velocity : Vector2 #Veclocity from other sources (grapple hook, dash, etc.)

var is_jumping : bool
var can_jump : bool

var direction : int = 1

func _process(delta: float) -> void:
	
	velocity.y += gravity
	
	#Jump control
	if Input.is_action_just_pressed("Jump"):
		can_jump = true
		jump_buffer_timer.start(jump_buffer)
	
	if Input.is_action_just_released("Jump"):
		can_jump = false
		is_jumping = false
		if velocity.y < 0:
			velocity.y += jump_end_force
	
	if can_jump and is_on_floor():
		is_jumping = true
		can_jump = false
		jump_timer.start(jump_length)
	
	if is_jumping:
		velocity.y = -jump_speed
	
	#Run control
	if Input.is_action_just_pressed("Right"):
		direction = 1
	elif Input.is_action_just_released("Right") and Input.is_action_pressed("Left"):
		direction = -1
	
	if Input.is_action_just_pressed("Left"):
		direction = -1
	elif Input.is_action_just_released("Left") and Input.is_action_pressed("Right"):
		direction = 1
	
	if Input.is_action_pressed("Right") or Input.is_action_pressed("Left"):
		velocity.x += acceleration * direction * delta
		if velocity.x > speed:
			velocity.x = speed
		if velocity.x < -speed:
			velocity.x = -speed
	elif velocity.x < -floor_friction * delta or velocity.x > floor_friction * delta:
		velocity.x -= direction * floor_friction * delta
	else:
		velocity.x = 0
	
	move_and_slide()

func _on_jump_length_timeout() -> void:
	is_jumping = false

func _on_jump_buffer_timeout() -> void:
	can_jump = false
