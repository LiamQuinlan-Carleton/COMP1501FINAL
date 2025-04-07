extends CharacterBody2D

#HP
@export var health : int = 3

#Movement "Feel" Variables

#Jump
@export var jump_speed : float
@export var jump_length : float #Time spent moving upwards at jump_speed
@export var jump_end_force : float #Applied when jump button released before peak of jump
@export var jump_buffer : float #Earliest time jump button can be pressed and still allow jump when reaches floor
@export var cyote_time : float
var lastSurface : String

#Run
@export var speed : float #Max run speed
@export var acceleration : float
@export var floor_friction : float
@export var air_resistance : float
@export var sliding_friction: float
@export var wall_friction: float 
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
@export var cyote_time_timer : Timer

#Logic variables
var is_jumping : bool #Is actively holding space to move upwards. Is false when space is let go or jump time runs out
var want_jump : bool #True when player has pressed space. False when jump starts or after buffer window passes
var can_jump : bool #True when player is able to jump
var can_shoot : bool = true #True when player isn't reloading or delayed between shots

var l_dir : int = 1 #last direction key pressed. -1 = Left, 1 = Right
var checking_above : bool = false # True if crouched and currently cant uncrouch, false if player can
var crouching: bool = false # True if the player is crouching, false otherwise
var want_to_stand: bool = false # True if the player wants to uncrouch
var can_stand: bool = true

#Grab hp progress bar node and ammo animated sprite node
@onready var hp = $"Camera2D/Health Bar"
@onready var ammo = $"Camera2D/Ammo Bar"
var current_ammo : int = 6
#Grab animatedsprite2d node
@onready var animation = $AnimatedSprite2D
var current_frame : int
var update_frame : bool = false
#Grab player collisionshape
@onready var player_hitbox = $CollisionShape2D

#Zipline variables
var in_zipline_area = false
var zipline_area : PathFollow2D
var on_zipline = false
@onready var ziplines = get_tree().get_nodes_in_group("Zipline")
@onready var main_node = get_parent()

# Level variables
@export var spawn : Vector2 = Vector2(0, 0) # spawn point 

var has_grapple : bool
@export var grapple_line : Line2D
var grapple_point : Vector2
@export var grapple_force : float
@export var grapple_distance : float

#The code bellow is in no way organized or easy to read. I apologize in advance.
func _physics_process(delta: float) -> void:
	hp.value = health
	velocity = get_real_velocity()
	
	#if (global_position.y > 1300):
		#global_position.x = 600
		#global_position.y = 550
	
	# don't fall when on zipline
	if is_instance_of(get_parent(), PathFollow2D):
		velocity.y = 0
	else:
		velocity.y += gravity*delta
	
	if on_zipline:
		velocity.x = 0
		velocity.y = 0
	
	#if Input.is_action_pressed("Shift"):
		#velocity.x -= 1000 * delta
	# Animation control
	if is_on_floor() and !crouching and !is_jumping and can_shoot:
		if (velocity.x > 10):
			animation.play("Run Right")
			current_frame = animation.frame
		elif (velocity.x < -10):
			animation.play("Run Left")
			current_frame = animation.frame
		else:
			animation.play("Idle")
			current_frame = animation.frame
	elif is_on_wall() and !crouching and !is_jumping and can_shoot:
		if (l_dir == 1):
			animation.play("Wall Slide Right")
		elif (l_dir == -1):
			animation.play("Wall Slide Left")
	elif (velocity.y > 70) and !crouching and !is_jumping and can_shoot:
		if (l_dir == 1):
			animation.play("Jump Right")
			animation.frame = 8
			animation.pause()
		else:
			animation.play("Jump Left")
			animation.frame = 8
			animation.pause()
	
	#Jump control
	if Input.is_action_just_pressed("Jump"):
		want_jump = true
		jump_buffer_timer.start(jump_buffer)
		if is_on_wall():
			if (l_dir < 0):
				animation.play("Jump Right")
			else:
				animation.play("Jump Left")
		else:
			if (l_dir > 0):
				animation.play("Jump Right")
			else:
				animation.play("Jump Left")

	if Input.is_action_just_released("Jump"):
		want_jump = false
		is_jumping = false
		if velocity.y < 0:
			velocity.y += jump_end_force
	
	if want_jump and is_on_floor() or (can_jump and want_jump and lastSurface == "floor"):
		want_jump = false
		is_jumping = true
		jump_timer.start(jump_length)
		if is_on_wall():
			if (l_dir < 0):
				animation.play("Jump Right")
			else:
				animation.play("Jump Left")
		else:
			if (l_dir > 0):
				animation.play("Jump Right")
			else:
				animation.play("Jump Left")
	
	if is_on_wall() or (can_jump and lastSurface == "wall"):
		apply_friction(wall_friction, air_resistance, sliding_friction, false, delta, false)
		if want_jump:
			want_jump = false
			is_jumping = true
			jump_timer.start(jump_length)
			if l_dir == 1:
				velocity.x = -1*speed
			else:
				velocity.x = speed
			if is_on_wall():
				if (l_dir < 0):
					animation.play("Jump Right")
				else:
					animation.play("Jump Left")
			else:
				if (l_dir > 0):
					animation.play("Jump Right")
				else:
					animation.play("Jump Left")
	
	if is_on_floor() or is_on_wall():
		can_jump = true
		if is_on_floor():
			lastSurface = "floor"
		else:
			lastSurface = "wall"
		cyote_time_timer.start(cyote_time)
	
	if is_jumping:
		velocity.y = -jump_speed

	
	#Crouch control
	if Input.is_action_just_pressed("crouch"):
		if (velocity.y > 25) and is_on_floor():
			if (velocity.x > 0):
				animation.play("Slope Right Start")
			else:
				animation.play("Slope Left Start")
		elif is_on_floor():
			if (velocity.x > 0):
				animation.play("Slide Right Start")
			else:
				animation.play("Slide Left Start")
		player_hitbox.scale.y = 0.5
		player_hitbox.position.y = 13
		
		crouching = true
		await get_tree().create_timer(0.4).timeout
		update_frame = true
		if (velocity.y > 0) and is_on_floor() and can_shoot:
			if (velocity.x > 0):
				animation.play("Slope Right")
			else:
				animation.play("Slope Left")
		elif is_on_floor() and can_shoot:
			if (velocity.x > 0):
				animation.play("Slide Right")
			else:
				animation.play("Slide Left")
	if Input.is_action_just_released("crouch"):
		want_to_stand = true
	if want_to_stand and crouching and can_stand:
		reset_after_crouch()
	
	if is_on_floor() and crouching and !is_jumping and update_frame and can_shoot:
		if (velocity.y > 50):
			if (velocity.x > 0):
				animation.play("Slope Right")
			else:
				animation.play("Slope Left")
		else:
			if (velocity.x > 0):
				animation.play("Slide Right")
			else:
				animation.play("Slide Left")
	
	#Run control
	if Input.is_action_just_pressed("Right"):
		l_dir= 1
	elif Input.is_action_just_released("Right") and Input.is_action_pressed("Left"):
		l_dir = -1
	if Input.is_action_just_pressed("Left"):
		l_dir = -1
	elif Input.is_action_just_released("Left") and Input.is_action_pressed("Right"):
		l_dir = 1
	if (Input.is_action_pressed("Right") or Input.is_action_pressed("Left")) and !on_zipline:
		if sign(velocity.x) * velocity.x <= speed or sign(velocity.x) != sign(l_dir):
			velocity.x += acceleration * l_dir * delta
			if velocity.x > speed:
				velocity.x = speed
			if velocity.x < -speed:
				velocity.x = -speed
	else:
		apply_friction(floor_friction, air_resistance, sliding_friction, is_on_floor(), delta, true)
	
	if Input.is_action_just_pressed("Right Click"):
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(position, position + (get_global_mouse_position() - position).normalized() * grapple_distance)
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.collision_mask = 4
		var result = space_state.intersect_ray(query)
		if result:
			has_grapple = true
			grapple_point = result.collider.get_parent().position
			grapple_line.show()
			#print("Hello")
	if Input.is_action_pressed("Right Click") and has_grapple:
		velocity += grapple_force * Vector2(grapple_point - position).normalized()
		grapple_line.set_point_position(0, Vector2(0,0))
		grapple_line.set_point_position(1, grapple_point - (position + velocity * delta))
	if Input.is_action_just_released("Right Click"):
		has_grapple = false
		grapple_line.hide()
	
	Global.player_position = global_position
	
	move_and_slide()
	
	# if within zipline's interaction area
	if in_zipline_area:
		# when holding interact, player follows zipline's path
		if Input.is_action_pressed("Shift"):
			reparent(zipline_area)
			on_zipline = true
	# when releasing interact, player reparents itself to main, no longer follows zipline's path

		if on_zipline:
			#print(get_parent().get_parent().get_parent().at_end)
			if Input.is_action_just_released("Shift") or get_parent().get_parent().get_parent().at_end :
				reparent(main_node)
				on_zipline = false 
				in_zipline_area = false

# Runs every frame
func _process(delta: float) -> void:
	# die and respawn if health runs out or fell off map
	if health <= 0:
		call_deferred("reset_player")

#x is true
func apply_friction(f_frict : float, a_resist : float, s_frict : float, floor : bool, delta : float, x_or_y : bool):
	if x_or_y:
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
	else: 
		var dir = sign(velocity.y)
		var vel_to_remove : float = velocity.y*f_frict
		velocity.y -= vel_to_remove * delta
		

# Handle inputs
func _input(event: InputEvent) -> void:
	# Handle's shooting input
	if event.is_action_pressed("Left Click"):
		if can_shoot and current_ammo > 0:
			can_shoot = false
			Global.shoot.emit()
			shoot_timer.start(shoot_cooldown)
			current_ammo -= 1
			if is_on_floor() and velocity.x == 0:
				animation.play("Idle Shoot")
				animation.frame = current_frame + 1
			elif is_on_floor() and !crouching:
				if (velocity.x > 0):
					animation.play("Run Shoot Right")
					animation.frame = current_frame + 1
				elif (velocity.x < 0):
					animation.play("Run Shoot Left")
					animation.frame = current_frame + 1
			elif is_on_floor() and crouching:
				if (velocity.y > 50):
					if (velocity.x > 0):
						animation.play("Slope Right Shoot")
					else:
						animation.play("Slope Left Shoot")
				else:
					if (velocity.x > 0):
						animation.play("Slide Right Shoot")
					else:
						animation.play("Slide Left Shoot")
			elif is_on_wall():
				if (l_dir == -1):
					animation.play("Wall Slide Shoot Right")
					animation.frame = current_frame + 1
				elif (l_dir == 1):
					animation.play("Wall Slide Shoot Left")
					animation.frame = current_frame + 1
			else:
				if (velocity.x > 0):
					animation.play("Jump Shoot Right")
					animation.frame = current_frame + 1
				elif (velocity.x < 0):
					animation.play("Jump Shoot Left")
					animation.frame = current_frame + 1
			ammo.play("Shoot")
			await get_tree().create_timer(0.2).timeout
			ammo.pause()
			ammo.frame = 24 - current_ammo * 4
			if current_ammo == 0:
				ammo.play("Reload")
				await get_tree().create_timer(1.51).timeout
				current_ammo = 6
	if event.is_action_pressed("Reset"): # For quick resets
		call_deferred("reset_player")

func _on_jump_length_timeout() -> void:
	is_jumping = false

func _on_jump_buffer_timeout() -> void:
	want_jump = false

func _on_cyote_time_timeout() -> void:
	can_jump = false

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
	want_to_stand = false
	update_frame = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	var area_array = $Area2D.get_overlapping_areas()
	in_zipline_area = true
	#if (area_array.size() > 1):
		#in_zipline_area = true;
	
	# set zipline_area to the area of the zipline the player's overlapping with
	
	for a in area_array[0].get_parent().get_children() :
		if is_instance_of(a, Path2D) :
			for b in a.get_children():
				if is_instance_of(b, PathFollow2D):
					zipline_area = b
					

func _on_area_2d_area_exited(area: Area2D) -> void:
	#print("exited ", area, " ", area.get_parent())
	if (!is_instance_of(get_parent(), PathFollow2D)):
		in_zipline_area = false;

func _on_upper_collision_body_entered(body: TileMapLayer) -> void:
	can_stand = false

func _on_upper_collision_body_exited(body: TileMapLayer) -> void:
	can_stand = true

func _on_death_collisions_died() -> void:
	call_deferred("reset_player")

func reset_player():
	Global.attempts_taken += 1
	get_tree().reload_current_scene()
