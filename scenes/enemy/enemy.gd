extends Area2D

signal died

@onready var screensize = get_viewport_rect().size
@onready var move_timer: Timer = $MoveTimer
@onready var shoot_timer: Timer = $ShootTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var start_pos = Vector2.ZERO
var speed = 0
var bullet_scene = preload("res://scenes/enemy_bullet/enemy_bullet.tscn")

func start(pos: Vector2) -> void:
	reset_enemy(pos)
	spawn_enemy()
	reset_move_timer()
	reset_shoot_timer()
	
	
func reset_enemy(pos: Vector2) -> void:
	speed = 0
	position = Vector2(pos.x, -pos.y)
	start_pos = pos
	
	
func reset_move_timer() -> void:
	move_timer.wait_time = randf_range(5, 20)
	move_timer.start()
	
	
func reset_shoot_timer() -> void:
	shoot_timer.wait_time = randf_range(4, 20)
	shoot_timer.start()
	
	
func spawn_enemy() -> void:
	await get_tree().create_timer(randf_range(0.25, 0.55)).timeout
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:y", start_pos.y, 1.4)
	await tween.finished
	

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > screensize.y +32:
		start(start_pos)
		
		
func explode() -> void:
	speed = 0
	animation_player.play("explode")
	await  animation_player.animation_finished
	died.emit(5)
	queue_free()
	
func shoot() -> void:
	var bullet_scene_instance = bullet_scene.instantiate()
	get_tree().root.add_child(bullet_scene_instance)
	bullet_scene_instance.start(position)
	shoot_timer.wait_time = randf_range(4, 20)
	shoot_timer.start()


func _on_move_timer_timeout() -> void:
	speed = randf_range(75, 100)


func _on_shoot_timer_timeout() -> void:
	shoot()
	reset_shoot_timer()
