extends Node2D

@onready var zipline : PathFollow2D = $Path2D/PathFollow2D
@onready var main_node = get_parent()

@export var speed = 50
@export var acceleration = 1.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Zipline")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# if PathFollow2D has Player as a child, start its progress
	if (($Path2D/PathFollow2D.get_children()).size() > 1):     # WITH SPRITE, CHANGE NUMBER WHEN REMOVING SPRITE
		var player = $Path2D/PathFollow2D.get_child(1)
		player.velocity.x = 0
		print(zipline.progress)
		
		# zipline progress only moves when player hasn't reached the end yet
		if player.global_position.x +10 < self.global_position.x :
			# moving and accelerating on zipline
			zipline.progress += speed * delta
			speed *= acceleration
		
		#if zipline.progress_ratio < 0.1 :    # remove when removing loop
			#speed = 100
	
	# when player isn't on zipline, reset zipline and speed
	else:
		zipline.progress_ratio = 0
		speed = 50
