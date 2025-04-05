extends Control

@export var time : float
@export var ended : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/PanelContainer.hide()
	$Timer.wait_time = time
	$Timer.start()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CanvasLayer/Label.text = "%d:%02d" % [floor($Timer.time_left / 60), int($Timer.time_left) % 60]

func end_level():
	ended = true
	get_tree().paused = true
	var final_time : float = $Timer.wait_time - $Timer.get_time_left()
	$Timer.stop()
	$CanvasLayer/PanelContainer/VBoxContainer/Time_left.text = str(final_time).pad_decimals(2) + "s"
	$CanvasLayer/PanelContainer.show()


func _on_timer_timeout() -> void:
	call_deferred("reset_scene")

func reset_scene():
	get_tree().reload_current_scene()


func _on_retry_pressed() -> void:
	get_tree().paused = false
	call_deferred("reset_scene")


func _on_return_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level_select.tscn")
