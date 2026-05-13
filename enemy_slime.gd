extends CharacterBody2D

@export var move_speed: float = 100.0
@export var aggro_range: float = 200.0

var player: CharacterBody2D
var is_aggro: bool = false
var battle_started: bool = false

func _ready():
	player = get_node("../Player")
	if not player:
		player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player or battle_started:
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance < aggro_range:
		is_aggro = true
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
	
	if distance < 30:
		battle_started = true
		_prepare_battle()
		call_deferred("_start_battle_deferred")

func _prepare_battle():
	var hp = 100
	var atk = 15
	var hit = 0.8
	var crit_c = 0.1
	var crit_m = 1.5
	
	if player.has_method("get_attack_power"):
		hp = player.get("base_max_hp") if "base_max_hp" in player else 100
		atk = player.get("base_attack") if "base_attack" in player else 15
		hit = player.get("base_hit_chance") if "base_hit_chance" in player else 0.8
		crit_c = player.get("base_crit_chance") if "base_crit_chance" in player else 0.1
		crit_m = player.get("base_crit_multiplier") if "base_crit_multiplier" in player else 1.5
	
	GlobalBattle.player_stats = {
		"max_hp": hp,
		"current_hp": hp,
		"attack": atk,
		"hit_chance": hit,
		"crit_chance": crit_c,
		"crit_multiplier": crit_m
	}
	
	GlobalBattle.enemy_path = get_path()
	hide()
	set_physics_process(false)

func _start_battle_deferred():
	get_tree().change_scene_to_file("res://battle_scene.tscn")
