extends Control

@export var time : float
@export var ended : bool = false

@onready var time_taken = $CanvasLayer/PanelContainer/VBoxContainer/Time_left
@onready var attempts_taken = $CanvasLayer/PanelContainer/VBoxContainer/Attempts_taken
@onready var l_select_res = preload("res://level_select.tscn")
@onready var levels = get_tree().get_nodes_in_group("levelIcons")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/PanelContainer.hide()
	ended = false
	get_tree().paused = false
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
	time_taken.text = "Time Taken: " + str(final_time).pad_decimals(2) + "s"
	attempts_taken.text = "Attempts Taken: " + str(Global.attempts_taken)
	$CanvasLayer/PanelContainer.show()


func _on_timer_timeout() -> void:
	call_deferred("reset_scene")

func reset_scene():
	Global.attempts_taken = 1
	get_tree().reload_current_scene()


func _on_retry_pressed() -> void:
	get_tree().paused = false
	call_deferred("reset_scene")


func _on_return_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level_select.tscn")


func _on_next_pressed() -> void:
	var l_sel = l_select_res.instantiate()
	var s = levels.size()
	print(s)
	print(levels)
	l_sel._on_next_level(levels, s)
