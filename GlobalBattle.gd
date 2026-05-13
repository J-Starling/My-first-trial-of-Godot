extends Node

var player_stats: Dictionary = {
	"max_hp": 100,
	"current_hp": 100,
	"attack": 15,
	"hit_chance": 0.8,
	"crit_chance": 0.1,
	"crit_multiplier": 1.5
}

var enemy_path: NodePath = NodePath()
var pending_experience: int = 0
var experience_reward: int = 30
