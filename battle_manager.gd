extends Node

@onready var player = $"../Player"
@onready var enemy = $"../Enemy"
@onready var player_hp_bar: ProgressBar = $"../CanvasLayer/PlayerHPBar"
@onready var enemy_hp_bar: ProgressBar = $"../CanvasLayer/EnemyHPBar"
@onready var battle_log: RichTextLabel = $"../CanvasLayer/BattleLog"
@onready var attack_button: Button = $"../CanvasLayer/AttackButton"

func _ready():
	if GlobalBattle.player_stats and not GlobalBattle.player_stats.is_empty():
		player.setup_from_dict(GlobalBattle.player_stats)
	
	player_hp_bar.max_value = player.max_hp
	player_hp_bar.value = player.current_hp
	player.hp_changed.connect(_on_player_hp_changed)
	battle_log.append_text("\n" + player.character_name + " готов к бою! HP: " + str(player.current_hp))
	
	enemy_hp_bar.max_value = enemy.max_hp
	enemy_hp_bar.value = enemy.current_hp
	enemy.hp_changed.connect(_on_enemy_hp_changed)
	battle_log.append_text("\n" + enemy.character_name + " нападает! HP: " + str(enemy.current_hp))
	
	log_message("Бой начинается!")
	attack_button.grab_focus()

func _on_player_hp_changed(new_hp):
	create_tween().tween_property(player_hp_bar, "value", new_hp, 0.5)

func _on_enemy_hp_changed(new_hp):
	create_tween().tween_property(enemy_hp_bar, "value", new_hp, 0.5)

func _on_attack_button_pressed():
	attack_button.disabled = true
	player_attack()

func player_attack():
	log_message("\n[color=cyan]Ход игрока[/color]")
	execute_attack(player, enemy)
	
	if enemy.current_hp > 0:
		await get_tree().create_timer(0.8).timeout
		enemy_attack()
	else:
		await get_tree().create_timer(1.0).timeout
		on_victory()

func enemy_attack():
	log_message("\n[color=orange]Ход врага[/color]")
	execute_attack(enemy, player)
	
	if player.current_hp <= 0:
		await get_tree().create_timer(1.0).timeout
		on_defeat()
	else:
		attack_button.disabled = false
		attack_button.grab_focus()

func log_message(text: String):
	battle_log.append_text("\n" + text)

func execute_attack(attacker: Fighter, target: Fighter):
	if randf() > attacker.hit_chance:
		log_message("[color=gray]" + attacker.character_name + " промахнулся![/color]")
		return

	var damage = randi_range(attacker.attack_power - 2, attacker.attack_power + 5)
	var is_crit = randf() <= attacker.crit_chance
	
	if is_crit:
		damage = int(damage * attacker.crit_multiplier)
		log_message("[color=red][b]КРИТ![/b][/color] " + attacker.character_name + " вмазал на [b]" + str(damage) + "[/b] урона!")
	else:
		log_message(attacker.character_name + " нанес [b]" + str(damage) + "[/b] урона.")

	target.take_damage(damage)
	
	if target.current_hp <= 0:
		log_message("[color=yellow]" + target.character_name + " повержен![/color]")

func on_victory():
	attack_button.disabled = true
	log_message("\n[color=yellow][b]ПОБЕДА![/b][/color]")
	log_message("Получено [b]" + str(GlobalBattle.experience_reward) + "[/b] опыта.")
	
	GlobalBattle.pending_experience = GlobalBattle.experience_reward
	
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://World.tscn")

func on_defeat():
	attack_button.disabled = true
	log_message("\n[color=red][b]ПОРАЖЕНИЕ![/b][/color]")
	log_message("Возвращаемся в мир...")

	GlobalBattle.pending_experience = 0
	
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://World.tscn")
