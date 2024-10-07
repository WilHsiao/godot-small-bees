extends Node2D

@onready var start_button: TextureButton = $CanvasLayer/CenterContainer/StartButton
@onready var game_over: TextureRect = $CanvasLayer/CenterContainer/GameOver

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var score = 0

var row_enemies_count = 9
var column_enemies_count = 3
var total_enemies = 0

func _ready() -> void:
	start_button.show()
	game_over.hide()
	get_tree().paused = true

func spawn_all_enemies():
	for x in range(9):
		for y in range(3):
			var enemy_scene_instance = enemy_scene.instantiate()
			var pos = Vector2(x * (16 + 8) + 24, 16 * 4 + y * 16)
			add_child(enemy_scene_instance)
			enemy_scene_instance.start(pos)
			enemy_scene_instance.died.connect(on_enemy_died)
			
			
func on_enemy_died(value) -> void:
	score += value			
	$CanvasLayer/UI.update_score(score)
	total_enemies -= 1
	if total_enemies !=0:
		return
	start_button.show()
	get_tree().paused = true


func _on_start_button_pressed() -> void:
	start_button.hide()
	new_game()
	get_tree().paused = false
	
func new_game() -> void:
	score =  0
	$CanvasLayer/UI.update_score(score)
	$Player.start()
	$Player.reset_shield()  
	$Player.show()
	spawn_all_enemies()
	total_enemies = column_enemies_count * row_enemies_count


func _on_player_died() -> void:
	get_tree().paused = true
	get_tree().call_group("enemies", "queue_free")
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()
