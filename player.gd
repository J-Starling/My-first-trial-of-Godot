extends CharacterBody2D

@onready var level_label: Label = $"../CanvasLayer/LevelLabel"

@export var speed: float = 300.0

var level: int = 1
var experience: int = 0
var experience_to_next: int = 50

var base_max_hp: int = 100
var base_attack: int = 15
var base_hit_chance: float = 0.8
var base_crit_chance: float = 0.1
var base_crit_multiplier: float = 1.5

signal leveled_up

func _ready():
	add_to_group("player")
	
	# Показываем джойстик только на мобильных платформах
	_setup_joystick()
	
	leveled_up.connect(update_level_label)
	update_level_label()
	
	# Опыт после боя
	if GlobalBattle.pending_experience > 0:
		gain_experience(GlobalBattle.pending_experience)
		GlobalBattle.pending_experience = 0
	
	# Удаление врага
	if not GlobalBattle.enemy_path.is_empty():
		var enemy_node = get_node_or_null(GlobalBattle.enemy_path)
		if enemy_node:
			enemy_node.queue_free()
		GlobalBattle.enemy_path = NodePath()

func _setup_joystick():
	var joystick = get_node_or_null("../CanvasLayer/Joystick")
	if not joystick:
		return
	
	# Показываем только на Android или iOS
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		joystick.show()
		print("Мобильная платформа — джойстик включён")
	else:
		joystick.hide()
		print("Десктоп — джойстик скрыт")

func _physics_process(delta: float):
	var direction = Vector2.ZERO
	
	# Клавиатура (всегда работает)
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1
	
	# Джойстик (если видим)
	var joystick = get_node_or_null("../CanvasLayer/Joystick")
	if joystick and joystick.visible and joystick.has_method("get_velocity"):
		var joy_vel = joystick.get_velocity()
		if joy_vel.length() > 0.1:
			direction = joy_vel
	
	direction = direction.normalized()
	
	if direction:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	move_and_slide()
	
	if direction.length() > 0.1:
		var angle = direction.angle()
		rotation = lerp_angle(rotation, angle, 0.1)

func gain_experience(amount: int):
	experience += amount
	while experience >= experience_to_next:
		level_up()
	update_level_label()

func level_up():
	experience -= experience_to_next
	level += 1
	experience_to_next = int(experience_to_next * 1.5)
	
	base_max_hp += 20
	base_attack += 5
	base_crit_chance = min(base_crit_chance + 0.02, 0.5)
	base_crit_multiplier += 0.1
	
	print("Level Up! Now level ", level)
	leveled_up.emit()

func update_level_label():
	if level_label:
		level_label.text = "Lvl: " + str(level) + " | Exp: " + str(experience) + "/" + str(experience_to_next)
