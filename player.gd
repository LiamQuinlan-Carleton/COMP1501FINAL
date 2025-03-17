extends CharacterBody2D

#Movement "Feel" Variables

#Jump
@export var jump_speed : float
@export var jump_length : float #Time spent moving upwards at jump_speed
@export var jump_end_force : float #Applied when jump button released before peak of jump
@export var jump_buffer : float #Earliest time jump button can be pressed and still allow jump when reaches floor

#Run
@export var speed : float #Max run speed
@export var acceleration : float
@export var floor_friction : float
@export var air_resistance : float

#Misc
@export var gravity : float

#Timer Nodes
@export var jump_timer : Timer #Time with constant jump velocity

#Player can press jump before touching ground and still jump once they land. 
#This is the time allowed between pressing button and jumping
@export var jump_buffer_timer : Timer 
#@export var cyote_time_timer : Timer

#Logic variables
var is_jumping : bool #Is actively holding space to move upwards. Is false when space is let go or jump time runs out
var want_jump : bool #True when player has pressed space. False when jump starts or after buffer window passes
var can_jump: bool #True  when player is able to jump

var l_dir : int = 1 #last direction key pressed. -1 = Left, 1 = Right

#The code bellow is in no way organized or easy to read. I apologize in advance.
func _process(delta: float) -> void:
	
	velocity.y += gravity
	
	if Input.is_action_pressed("Shift"):
		velocity.x -= 1000 * delta
	
	#Jump control
	if Input.is_action_just_pressed("Jump"):
		want_jump = true
		jump_buffer_timer.start(jump_buffer)
	
	if Input.is_action_just_released("Jump"):
		want_jump = false
		is_jumping = false
		if velocity.y < 0:
			velocity.y += jump_end_force
	
	if want_jump and is_on_floor():
		want_jump = false
		is_jumping = true
		jump_timer.start(jump_length)
	
	if is_jumping:
		velocity.y = -jump_speed
	
	#Run control
	if Input.is_action_just_pressed("Right"):
		l_dir= 1
	elif Input.is_action_just_released("Right") and Input.is_action_pressed("Left"):
		l_dir = -1
	
	if Input.is_action_just_pressed("Left"):
		l_dir = -1
	elif Input.is_action_just_released("Left") and Input.is_action_pressed("Right"):
		l_dir = 1
	
	if Input.is_action_pressed("Right") or Input.is_action_pressed("Left"):
		if sign(velocity.x) * velocity.x <= speed:
			velocity.x += acceleration * sign(velocity.x) * delta
			if velocity.x > speed:
				velocity.x = speed
			if velocity.x < -speed:
				velocity.x = -speed
	else:
		apply_friction(floor_friction, air_resistance, is_on_floor(), delta)
	
	move_and_slide()


func apply_friction(f_frict : float, a_resist : float, floor : bool, delta : float):
	
	var dir = sign(velocity.x)
	
	var vel_to_remove : float
	if is_on_floor():
		vel_to_remove = f_frict
	else:
		vel_to_remove = a_resist
	
	velocity.x -= dir * vel_to_remove * delta
	if dir * velocity.x < 0:
		velocity.x = 0

func _on_jump_length_timeout() -> void:
	is_jumping = false

func _on_jump_buffer_timeout() -> void:
	want_jump = false
