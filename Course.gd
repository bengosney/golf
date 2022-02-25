extends TileMap

signal init_level

const BACKGROUND_LAYER = 1

export(int) var level_seed: int = 0
export(Vector2) var map_size: Vector2 = Vector2(80, 40)

export(int) var level: int = 1


func _ready():
	init_level(self)

func init_level(map):
	var noise = OpenSimplexNoise.new()

	if level_seed == 0:
		level_seed = hash(OS.get_date())

	noise.seed = level_seed + level
	noise.octaves = 4
	noise.period = 40
	noise.persistence = 0.8

	map.clear()

	var cell_size = map.cell_size
	var map_extents = cell_size * map_size

	var base_line = 5
	var max_height = 6

	var inc = TAU / map_size.x
	var radius = map_size.x / 2

	for x in range(-map_size.x, map_size.x * 2):
		var rads = x * inc

		var nx = radius * cos(rads)
		var ny = radius * sin(rads)

		var h = floor(noise.get_noise_2d(nx, ny) * max_height)

		var height = base_line + h

		for i in range(max_height * 10):
			if i >= height:
				map.set_cell(x, i, BACKGROUND_LAYER)

		if x == map_size.x:
			$Pin.position = map.map_to_world(Vector2(x, height)) - Vector2(0, map.cell_size.y / 2)

	var map_cells = map.get_used_cells_by_id(BACKGROUND_LAYER)
	for cell in map_cells:
		if !map_cells.has(cell + Vector2.LEFT) and !map_cells.has(cell + Vector2.RIGHT):
			map.set_cellv(cell + Vector2.RIGHT, BACKGROUND_LAYER)

	map.update_dirty_quadrants()
	map.update_bitmask_region()


func _on_Pin_hit_pin():
	emit_signal("init_level")
