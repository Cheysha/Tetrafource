@tool
extends Node

var scene 

const default_meta = ["gid", "height", "width", "imageheight", "imagewidth", "path"]

func _post_process(imported_scene):

	scene = imported_scene
	scene.set_script(load("res://engine/game.gd"))
	set_properties(scene, scene)
	
	var z = 0
	var children = scene.get_children()
	for child in children:
		if child is TileMap:
			child.z_index = z
			z += 1
			import_tilemap(child)
		elif child is Node2D:
			if child.name == "zones":
				for zone in child.get_children():
					#EDITED 12/4
					zone.get_node("Rectangle Shape").shape.size -= Vector2(8,8)
					zone.set_collision_layer_value(1, 0)
					zone.set_collision_mask_value(1, 0)
					#zone.set_collision_layer_value(10, 1)
					#zone.set_collision_mask_value(10, 1)
					#CHEY
					zone.set_collision_layer_value(11, 1)
					zone.set_collision_mask_value(11, 1)
					zone.set_script(preload("res://engine/zone.gd"))
					set_properties(zone, zone)
				continue
			for object in child.get_children():
				spawn_object(object)
			child.free()
	
	return scene

func import_tilemap(tilemap:TileMap):
	tilemap.z_index -= 10
	# EDITED 12/4
	#tilemap.set_collision_layer_value(1,1)
	#tilemap.set_collision_mask_value(1,1)
	#tilemap.position.y += 16 # think this was traced to an issue with a lyer in the tilemap. 
	if tilemap.has_meta("script"):
		tilemap.set_script(load(tilemap.get_meta("script")))
	if tilemap.has_meta("replace"):
		replace_tilemap(tilemap, tilemap.get_meta("replace"))
		return
	if tilemap.has_meta("z_index"):
		tilemap.z_index = tilemap.get_meta("z_index")
	# EDITED 12/4
	#if tilemap.has_meta("collision"):
		#tilemap.set_collision_layer_value(0, 0)
		#tilemap.set_collision_layer_value(1, 0)
		#tilemap.set_collision_mask_value(0, 0)
		#tilemap.set_collision_mask_value(1, 0)

func spawn_object(object : Node2D):
	print("here")
	if object.has_meta("path"): 
		var path = object.get_meta("path")
		var node :Node2D = load(path).instantiate()
		print(path)
		print_debug("path ", path)
		print_debug("obj ",object.name)
		print_debug("node ", node.name)
		node.name = object.name
		scene.add_child(node)
		node.set_owner(scene)
		node.position = object.position + Vector2(8,-8)
		########################################################## not me below
		#node.scale.x = object.get_meta("width") / 16
		#node.scale.y = object.get_meta("height") / 16
		#node.position += Vector2((node.scale.x-1)*8, -(node.scale.y-1)*8)
		set_properties(object, node)
	
	else:
		object.get_parent().remove_child(object)
		scene.add_child(object)
		object.set_owner(scene)

func replace_tilemap(tilemap : TileMap, replace ):
	var used_cells = tilemap.get_used_cells(0)
	var replacement : TileMap = load(replace).instantiate()
	tilemap.free()
	scene.add_child(replacement)
	replacement.set_owner(scene)
	for cell in used_cells:
		# EDITED 12/4
		#replacement.set_cellv(cell, 0)
		replacement.set_cell(0, cell, -1, Vector2(0,0)) # i think this is it
		#replacement.update_bitmask_region()

func set_properties(object, node):
	for meta in object.get_meta_list():
		if meta in default_meta:
			continue
		node.set(meta, object.get_meta(meta))
