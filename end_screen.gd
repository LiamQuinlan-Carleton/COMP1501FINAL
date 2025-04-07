extends Control

@export var time : float
@export var ended : bool = false

@onready var time_taken = $CanvasLayer/PanelContainer/VBoxContainer/Time_left
@onready var attempts_taken = $CanvasLayer/PanelContainer/VBoxContainer/Attempts_taken
@onready var next_level_button = $CanvasLayer/PanelContainer/VBoxContainer/Next

@onready var levels = {
	0: "res://Levels/level_1.tscn",
	1: "res://Levels/level_2.tscn",
	2: "res://Levels/level_3.tscn",
	3: "res://Levels/level_4.tscn",
	4: "res://Levels/level_5.tscn",
	5: "res://Levels/level_6.tscn",
	6: "res://Levels/level_7.tscn",
	7: "res://Levels/level_8.tscn",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_level_button.visible = true
	$CanvasLayer/PanelContainer.hide()
	ended = false
	get_tree().paused = false
	$Timer.wait_time = time
	$Timer.start()
	if Global.current_level == 7:
		next_level_button.visible = false

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
	Global.current_level += 1
	get_tree().change_scene_to_file(levels[Global.current_level])
