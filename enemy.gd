extends RigidBody2D

#Shoot
@export var shoot_cooldown : float
#HP
@export var health : int = 3

#Timer Nodes
@export var shoot_timer : Timer #Time between shooting bullets

#Logic variables
var can_shoot : bool = true #True when player isn't reloading or delayed between shots
@export var current_level: String
#Grab raycast node for line of sight
@onready var los = $LineOfSight
#Grab animation node
@onready var animation = $AnimatedSprite2D
var current_frame
#Grab player node
@onready var player = get_tree().get_root().find_child("Player", true, false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	los.target_position = player.global_position - los.global_position
	if (los.target_position.x<0) and can_shoot:
		animation.play("Idle Left")
		current_frame = animation.frame
	elif can_shoot:
		animation.play("Idle Right")
		current_frame = animation.frame
	elif (los.target_position.x<0) and !can_shoot:
		animation.play("Shoot Left")
		animation.frame = current_frame + 1
	else:
		animation.play("Shoot Right")
		animation.frame = current_frame + 1
	var collider = los.get_collider()
	if collider == player:
		if can_shoot:
			Global.enemy_shoot.emit(self)
			can_shoot = false
			shoot_timer.start()
	if health <= 0:
		queue_free()

#Called when player deals damage to this enemy
func deal_damage(amount):
	health -= amount

func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true
