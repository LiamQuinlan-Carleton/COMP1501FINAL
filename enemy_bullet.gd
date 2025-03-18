extends Area2D

#Bullet move speed
@export var move_speed = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += Vector2(cos(rotation), sin(rotation)) * move_speed * delta

#Set bullet in place
func start_position(enemy: RigidBody2D):
	global_position = enemy.global_position
	var target_position = Global.player_position
	var angle = (Global.player_position - global_position).normalized().angle()
	rotation = angle


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
		queue_free()
	else:
		queue_free()
