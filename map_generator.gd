extends Node2D

@onready var tile_map = $"../TileMapLayer"

var noise = FastNoiseLite.new()
@export var map_width: int = 20
@export var map_height: int = 20

func _ready():
	randomize()
	noise.seed = randi()
	noise.frequency = 0.2
	generate_map()

func generate_map():
	for x in range(map_width):
		for y in range(map_height):
			var n = noise.get_noise_2d(x, y)
			
			if n < -0.1:
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(2, 4))
			elif n < 0.4:
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(3, 2))
			else:
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(4, 2))
