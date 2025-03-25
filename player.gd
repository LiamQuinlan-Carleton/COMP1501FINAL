extends CharacterBody2D

#HP
@export var health : int = 3

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
@export var sliding_friction: float

#Shoot
@export var shoot_cooldown : float

#Misc
@export var gravity : float

#Timer Nodes
@export var jump_timer : Timer #Time with constant jump velocity
@export var shoot_timer : Timer #Time between shooting bullets

#Player can press jump before touching ground and still jump once they land. 
#This is the time allowed between pressing button and jumping
@export var jump_buffer_timer : Timer 
#@export var cyote_time_timer : Timer

#Logic variables
var is_jumping : bool #Is actively holding space to move upwards. Is false when space is let go or jump time runs out
var want_jump : bool #True when player has pressed space. False when jump starts or after buffer window passes
var can_jump : bool #True when player is able to jump
var can_shoot : bool = true #True when player isn't reloading or delayed between shots

var l_dir : int = 1 #last direction key pressed. -1 = Left, 1 = Right
var checking_above : bool = false # True if crouched and currently cant uncrouch, false if player can
var crouching: bool = false # True if the player is crouching, false otherwise
var want_to_stand: bool = false # True if the player wants to uncrouch

#Grab hp label node
@onready var hp = $"HP Label"
#Grab animatedsprite2d node
@onready var animation = $AnimatedSprite2D
#Grab player collisionshape
@onready var player_hitbox = $CollisionShape2D

#Zipline variables
var in_zipline_area = false
var zipline_area : PathFollow2D
var on_zipline = false
@onready var ziplines = get_tree().get_nodes_in_group("Zipline")
@onready var main_node = get_parent()

#The code bellow is in no way organized or easy to read. I apologize in advance.
func _physics_process(delta: float) -> void:
	hp.text = "Current HP: " + str(health)
	velocity = get_real_velocity()
	
	# don't fall when on zipline
	if is_instance_of(get_parent(), PathFollow2D):
		velocity.y = 0
	else:
		velocity.y += gravity*delta
	
	
	#if Input.is_action_pressed("Shift"):
		#velocity.x -= 1000 * delta
	
	#Jump control
	if Input.is_action_just_pressed("Jump"):
		want_jump = true
		jump_buffer_timer.start(jump_buffer)
		if (l_dir > 0):
			animation.frame = 0
			animation.play("Jump Right")
		else:
			animation.frame = 0
			animation.play("Jump Left")
	
	if Input.is_action_just_released("Jump"):
		want_jump = false
		is_jumping = false
		if velocity.y < 0:
			velocity.y += jump_end_force
	
	if want_jump and is_on_floor():
		want_jump = false
		is_jumping = true
		jump_timer.start(jump_length)
		
	if want_jump and is_on_wall():
		print(l_dir)
		want_jump = false
		is_jumping = true
		jump_timer.start(jump_length)
		if l_dir == 1:
			velocity.x = -1*speed
		else:
			velocity.x = speed
		
	if is_jumping:
		velocity.y = -jump_speed
	
	#Crouch control
	if Input.is_action_just_pressed("crouch"):
		if (l_dir > 0):
			animation.play("Slide Right Start")
		else:
			animation.play("Slide Left Start")
		player_hitbox.scale.y = 0.5
		player_hitbox.position.y = 13
		floor_stop_on_slope = false
		#floor_max_angle = 0
		crouching = true
		await get_tree().create_timer(0.5).timeout
		if (l_dir > 0):
			animation.play("Slide Right")
		else:
			animation.play("Slide Left")
	if $CheckCeiling.is_colliding():
			checking_above = true
	if Input.is_action_just_released("crouch"):
		want_to_stand = true
		if $CheckCeiling.is_colliding():
			checking_above = true
		else: 
			reset_after_crouch()
			want_to_stand = false
		#floor_max_angle = 45 Supposed to change sliding on slopes, broke the walls (fix later)
	if checking_above and crouching and want_to_stand:
		if not $CheckCeiling.is_colliding():
			reset_after_crouch()
			checking_above = false 
			want_to_stand = false
	
	#Run control
	if Input.is_action_just_pressed("Right"):
		l_dir= 1
		if !crouching and is_on_floor():
			animation.play("Run Right")
	elif Input.is_action_just_released("Right") and Input.is_action_pressed("Left"):
		l_dir = -1
		if !crouching and is_on_floor():
			animation.play("Run Left")
	if Input.is_action_just_pressed("Left"):
		l_dir = -1
		if !crouching and is_on_floor():
			animation.play("Run Left")
	elif Input.is_action_just_released("Left") and Input.is_action_pressed("Right"):
		l_dir = 1
		if !crouching and is_on_floor():
			animation.play("Run Right")
	if (Input.is_action_pressed("Right") or Input.is_action_pressed("Left")) and !on_zipline:
		if sign(velocity.x) * velocity.x <= speed:
			velocity.x += acceleration * l_dir * delta
			if velocity.x > speed:
				velocity.x = speed
			if velocity.x < -speed:
				velocity.x = -speed
	else:
		apply_friction(floor_friction, air_resistance, sliding_friction, is_on_floor(), delta)
	
	Global.player_position = global_position
	
	move_and_slide()
	
	
	# if within zipline's interaction area
	if in_zipline_area:
		# when holding interact, player follows zipline's path
		if Input.is_action_pressed("Shift"):
			reparent(zipline_area)
			on_zipline = true
	# when releasing interact, player reparents itself to main, no longer follows zipline's path
	if Input.is_action_just_released("Shift"):
		reparent(main_node)
		on_zipline = false


func apply_friction(f_frict : float, a_resist : float, s_frict : float, floor : bool, delta : float):
	
	var dir = sign(velocity.x)
	
	var vel_to_remove : float
	if is_on_floor():
		if Input.is_action_pressed("crouch"):
			vel_to_remove = s_frict
		else: 
			vel_to_remove = f_frict
	else:
		vel_to_remove = a_resist
	velocity.x -= dir * vel_to_remove * delta
	if dir * velocity.x < 0:
		velocity.x = 0

# Handle inputs
func _input(event: InputEvent) -> void:
	# Handle's shooting input
	if event.is_action_pressed("Left Click"):
		if can_shoot:
			Global.shoot.emit()
			can_shoot = false
			shoot_timer.start(shoot_cooldown)

func _on_jump_length_timeout() -> void:
	is_jumping = false

func _on_jump_buffer_timeout() -> void:
	want_jump = false

func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true

#Called when enemy deals damage to player
func take_damage(amount):
	health -= amount

# Puts player in proper position when standing back up
func reset_after_crouch():
	player_hitbox.scale.y = 1
	player_hitbox.position.y = 2
	floor_stop_on_slope = true
	crouching = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	in_zipline_area = true;
	
	# set zipline_area to the area of the zipline the player's overlapping with
	var area_array = $Area2D.get_overlapping_areas()
	for a in area_array:
		for b in a.get_parent().get_children() :
			if is_instance_of(b, Path2D) :
				for c in b.get_children():
					if is_instance_of(c, PathFollow2D):
						zipline_area = c

func _on_area_2d_area_exited(area: Area2D) -> void:
	in_zipline_area = false;
