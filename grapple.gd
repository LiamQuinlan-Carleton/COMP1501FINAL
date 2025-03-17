extends Node2D

@export var player : CharacterBody2D
@export var force : float
@export var line : Line2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Left Click"):
		line.show()
	if Input.is_action_pressed("Left Click"):
		player.velocity += force * Vector2(position - player.position).normalized()
		line.set_point_position(0, Vector2(0,0))
		line.set_point_position(1, player.position - position)
	if Input.is_action_just_released("Left Click"):
		line.hide()
