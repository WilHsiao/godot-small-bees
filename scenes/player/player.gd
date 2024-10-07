extends Area2D

signal died
signal shield_changed

@onready var screensize = get_viewport_rect().size
@onready var ship: Sprite2D = get_node("Ship")
@onready var boosters: AnimatedSprite2D = $Ship/Boosters
@onready var gun_cooldown_timer:Timer = $GunCooldownTimer

@export var speed = 150
@export var cooldown = 0.25
@export var bullet_scene: PackedScene
@export var max_shield = 10

var can_shoot = true
var ship_size = Vector2(16,16)
var shield = max_shield: set = set_shield

func _ready() -> void:
	start()

func start() -> void:
	position = Vector2(screensize.x / 2, screensize.y - 64)
	gun_cooldown_timer.wait_time = cooldown
	

func _process(delta):
	var input = Input.get_vector("left", "right", "up", "down")
	if input.x > 0:
		ship.frame = 2
		boosters.animation = "right"
	elif input.x < 0:
		ship.frame = 0
		boosters.animation = "left"
	else:
		ship.frame = 1
		boosters.animation = "forward"
	position += input * speed * delta
	position = position.clamp((ship_size / 2), screensize - (ship_size / 2))
	if Input.is_action_pressed("shoot"):
		shoot()
		
		
func shoot() -> void:
	if not can_shoot:
		return
	can_shoot = false
	gun_cooldown_timer.start()
	var bullet_scene_instance = bullet_scene.instantiate()
	get_tree().root.add_child(bullet_scene_instance)
	bullet_scene_instance.start(position + Vector2(0, - 8))
	
	
func set_shield(value) -> void:
	shield = min(max_shield, value)
	shield_changed.emit(max_shield, shield)
	if shield <= 0:
		hide()
		died.emit()
		
func reset_shield() -> void:
	shield = 100
		

func _on_gun_cooldown_timer_timeout() -> void:
	can_shoot = true


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.explode()
		shield -= max_shield / 2
		
		
		
