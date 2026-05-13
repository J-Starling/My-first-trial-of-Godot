extends Node

class_name Fighter

signal hp_changed(new_hp)

@export var character_name: String = "Воин"
@export var max_hp: int = 100
var current_hp: int

var attack_power: int = 15
var hit_chance: float = 0.8
var crit_chance: float = 0.2
var crit_multiplier: float = 2.0

func _ready():
	current_hp = max_hp

func setup_from_dict(stats: Dictionary):
	character_name = "Палыч"
	max_hp = stats["max_hp"]
	current_hp = stats["current_hp"]
	attack_power = stats["attack"]
	hit_chance = stats["hit_chance"]
	crit_chance = stats["crit_chance"]
	crit_multiplier = stats["crit_multiplier"]

func take_damage(amount: int):
	current_hp -= amount
	current_hp = max(0, current_hp)
	hp_changed.emit(current_hp)
