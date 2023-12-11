extends TileMap

var cut_cells = []: set = enter_cut_cells
var walkfx_texture = preload("res://effects/walkfx_grass.png")

func _ready():
	var network_object = preload("res://engine/network_object.tscn").instantiate()
	network_object.enter_properties = {"cut_cells":[]}
	network_object.persistent = false
	add_child(network_object)
	add_to_group("fxtile")

func cut(hitbox):
	var tile = local_to_map(hitbox.global_position)
	process_tile(tile)
	network.peer_call(self, "process_tile", [tile])
	
#EDITED 12/4
func enter_cut_cells(value):
	cut_cells = value
	for cell in cut_cells:
		pass
		#set_cellv(cell, -1)
	#update_bitmask_region()
	
#EDITED 12/4
func process_tile(tile : Vector2i):
		#if get_cellv(tile) == -1:
		#return
	if !get_cell_tile_data(0,tile):
		return

	cut_cells.append(tile)
	#set_cellv(tile, -1)
	set_cell(0,tile)
	#update_bitmask_region()
	var grass_cut = preload("res://effects/grass_cut.tscn").instantiate()
	network.current_map.add_child(grass_cut)
	grass_cut.global_position = map_to_local(tile) + Vector2(8,6)

	network.current_map.spawn_collectable("tetran", tile * 16 + Vector2i(8,8), 5)
