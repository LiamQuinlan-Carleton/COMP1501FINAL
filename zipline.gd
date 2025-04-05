extends Node2D

@onready var zipline : PathFollow2D = $Path2D/PathFollow2D
@onready var main_node = get_parent()

@export var speed = 50
@export var acceleration = 1.1
var chil
var at_end : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Zipline")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(at_end)
	
	# if PathFollow2D has Player as a child, start its progress
	if (($Path2D/PathFollow2D.get_children()).size() > 0):
		var player = $Path2D/PathFollow2D.get_child(0)
		
		# zipline progress only moves when player hasn't reached the end yet
		if player.global_position.x < self.global_position.x:
			# moving and accelerating on zipline
			zipline.progress += speed * delta
			speed *= acceleration
			
		if player.global_position.x > self.global_position.x or zipline.progress_ratio > 0.98:
			at_end = true
			
	# when player isn't on zipline, reset zipline and speed
	else:
		zipline.progress_ratio = 0
		speed = 50
		at_end = false
