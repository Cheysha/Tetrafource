extends TileMap

class_name Water

var default_cells = {}
var zone

func _ready():
	add_to_group("water")
	add_to_group("zoned")
	add_to_group("objects")
	pass
	#water auutotile
	#set_collision_layer_value(6, 1)
	#set_collision_mask_value(6, 1)
	#set_collision_layer_value(10, 1)
	#et_collision_mask_value(10, 1)
	for cell in get_used_cells(0):
		pass
		#default_cells[cell] = get_cellv(cell)

func clear_water(pos):
	var tile = local_to_map(pos)
	network.peer_call(self, "process_tile", [tile])
	#self.set_cellv(tile, -1)
	network.peer_call(self, "set_cellv", [tile, -1])

func is_cell_in_zone(cellv : Vector2, action_zone):
	
	# Convert zone into Rect2, so we check for points within it.
	# Worth noting that this only handles rectangle shapes
	var collision_rect = Rect2(action_zone.collision_shape.global_position - action_zone.shape.size,
		action_zone.shape.size*2)

	return collision_rect.has_point(map_to_local(cellv))

	
func set_default_state(action_zone):
	for cell in default_cells.keys():
		if is_cell_in_zone(cell, action_zone):
			#set_cellv(cell, default_cells[cell])
			#update_bitmask_area(cell)
			pass
