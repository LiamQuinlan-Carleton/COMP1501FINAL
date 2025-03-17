extends Node2D

#Signal emitted when player shoots
signal shoot
#Signal emitted when an enemy shoots
signal enemy_shoot

#Globally tracks player's current global position
var player_position = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
