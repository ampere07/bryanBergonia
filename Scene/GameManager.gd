extends Node

var score = 0
@onready var score_label = $"../ScoreLabel"

func _ready():
	# Score timer
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_increase_score)
	add_child(timer)
	timer.start()

func _increase_score():
	score += 1
	score_label.text = "Score: " + str(score)
