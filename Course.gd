extends TileMap

signal init_level

const BACKGROUND_LAYER = 1

export(int) var level_seed: int = 0
export(Vector2) var map_size: Vector2 = Vector2(80, 40)

export(int) var level: int = 1

var base_line = 5
var max_height = 6
var map = self

var _score: int = 0

var _max_x: int = 0
var _min_x: int = INF

onready var noise = OpenSimplexNoise.new()


func _ready():
	init_level()


func set_map_col(x, y = 0):
	var h = floor(noise.get_noise_2d(x, y) * max_height)
	var height = base_line + h
	for i in range(height, max_height * 10):
		map.set_cell(x, i, BACKGROUND_LAYER)

	return height


func init_level():
	if level_seed == 0:
		level_seed = hash(OS.get_date())

	noise.seed = level_seed + level
	noise.octaves = 4
	noise.period = 40
	noise.persistence = 0.8

	map.clear()

	var cell_size = map.cell_size
	var map_extents = cell_size * map_size

	var inc = TAU / map_size.x
	var radius = map_size.x / 2

	var y = 0
	for x in range(-map_size.x, map_size.x * 2):
		_min_x = min(_min_x, x)
		_max_x = max(_max_x, x)

		var height = set_map_col(x)

		if x == map_size.x:
			$Pin.position = map.map_to_world(Vector2(x, height)) + Vector2(map.cell_size.x / 2, 0)

	var map_cells = map.get_used_cells_by_id(BACKGROUND_LAYER)
	for cell in map_cells:
		if !map_cells.has(cell + Vector2.LEFT) and !map_cells.has(cell + Vector2.RIGHT):
			map.set_cellv(cell + Vector2.RIGHT, BACKGROUND_LAYER)

	map.update_dirty_quadrants()
	map.update_bitmask_region()


func _process(_delta):
	var player_x = map.world_to_map($Player.position).x
	var dist = _max_x - player_x
	if dist < map_size.x:
		var more = map_size.x - dist
		for x in range(_max_x, _max_x + more):
			set_map_col(x)

		_max_x += more
		#map.update_dirty_quadrants()
		map.update_bitmask_region(
			Vector2(_max_x - 1, base_line - 10), Vector2(_max_x + more, max_height + 10)
		)


func _on_Pin_hit_pin():
	emit_signal("init_level")


func _on_Player_hit_ball():
	_score += 1
	$HUD.set_score(_score)
