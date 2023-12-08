extends CharacterBody2D

class_name Entity

# ATTRIBUTES
@export var TYPE = "ENEMY" # (String, "ENEMY", "PLAYER", "TRAP")
@export var MAX_HEALTH = 1 # (float, 0.5, 20, 0.5)
@export var SPEED: int = 140
@export var DAMAGE = 0.5 # (float, 0, 20, 0.5)

# MOVEMENT
var movedir = Vector2(0,0)
var knockdir = Vector2(0,0)
var spritedir = "Down"
var last_movedir = Vector2(0,1)
var last_safe_pos = position

# COMBAT
var health = MAX_HEALTH: set = set_health
var hitstun = 0
var invunerable = 0
var hurt_sfx = "hit_hurt"
signal health_changed
signal update_count

var state = "default"
var home_position = Vector2(0,0)

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
var hitbox 
var center
var camera
#EDITED 12/4 FIX TWEEN 
#var tween : Tween
var walkfx
@onready var map = get_parent()

var pos = Vector2(0,0): set = position_changed
var animation = "idleDown": set = animation_changed

signal update_persistent_state

signal killed
signal damaged

func _ready():
	set_process(false)
	add_to_group("entity")
	
	map = get_game(self)
	
	if !sprite.material:
		sprite.material = ShaderMaterial.new()
		sprite.material.set_shader(preload("res://entities/entity.gdshader"))
	health = MAX_HEALTH
	home_position = position
	pos = position
	create_hitbox()
	create_center()
	
	#EDITED 12/4
	#tween = create_tween() 
	
	walkfx = preload("res://effects/walkfx.tscn").instantiate()
	add_child(walkfx)
	#map.connect("player_entered", self, "player_entered")
	set_collision_layer_value(10, 1)
	#set_collision_mask_value(10,1) not me 
	set_process(true)

func get_game(node):
	var game = node.get_parent()
	while game != null and not game.has_method("is_game"):
		game = game.get_parent()
	return game

func _process(delta):
	walkfx.hide()
	for body in center.get_overlapping_bodies():
		if body.is_in_group("fxtile"):
			walkfx.show()
			walkfx.frame = sprite.frame % 2
			walkfx.texture = body.walkfx_texture

func create_hitbox():
	var new_hitbox = Area2D.new()
	add_child(new_hitbox)
	new_hitbox.name = "Hitbox"
	
	var new_collision = CollisionShape2D.new()
	new_hitbox.add_child(new_collision)
	# EDITED
	
	var new_shape = CapsuleShape2D.new()
	new_collision.shape = new_shape
	new_shape.radius = $CollisionShape2D.shape.radius + 1
	new_shape.height = $CollisionShape2D.shape.height + 1
	
	new_hitbox.set_collision_layer_value(7,1)
	new_hitbox.set_collision_mask_value(7,1)
	
	hitbox = new_hitbox

func create_center():
	var new_center = Area2D.new()
	add_child(new_center)
	new_center.name = "Center"
	
	var new_collision = CollisionShape2D.new()
	new_center.add_child(new_collision)
	
	var new_shape = RectangleShape2D.new()
	new_collision.shape = new_shape
	new_shape.size = Vector2(1,1)
	
	# edited 12/4 
	new_center.set_collision_layer_value(1,0)
	new_center.set_collision_mask_value(1,0)
	new_center.set_collision_layer_value(5,1)
	new_center.set_collision_mask_value(5,1)
	new_center.set_collision_layer_value(6,1)
	new_center.set_collision_mask_value(6,1)
	new_center.set_collision_layer_value(7,1)
	new_center.set_collision_mask_value(7,1)
	
	new_center.position.y += 6
	center = new_center
	

func loop_movement():
	var motion
	if hitstun == 0:
		motion = movedir.normalized() * SPEED
	else:
		motion = knockdir.normalized() * 125
	
	set_velocity(motion)
	move_and_slide()
	
	pos = position
	
	if movedir != Vector2.ZERO:
		last_movedir = movedir

func loop_spritedir():
	var old_spritedir = spritedir
	
	match movedir:
		Vector2.LEFT:
			spritedir = "Left"
		Vector2.RIGHT:
			spritedir = "Right"
		Vector2.UP:
			spritedir = "Up"
		Vector2.DOWN:
			spritedir = "Down"
	
	sprite.flip_h = (spritedir == "Left")

func loop_damage():
	#EDIT
	if hitstun > 1:
		hitstun -= 1
	elif hitstun == 1:
		if sprite.material.get_shader_parameter("is_hurt") == true:
			set_hurt_texture(false)
			network.peer_call(self, "set_hurt_texture", [false])
		check_for_death()
		hitstun -= 1
	if invunerable > 1:
		invunerable -= 1
	elif invunerable == 1:
		if is_in_group("invunerable"):
			remove_from_group("invunerable")
		#anim.stop()
		invunerable -= 1
	
	if !hitbox.monitoring:
		return
	for area in hitbox.get_overlapping_areas():
		if area.name != "Hitbox":
			continue
		var body = area.get_parent()
		if !body.get_groups().has("entity"):
			continue
		if body.get("DAMAGE") > 0 && body.get("TYPE") != TYPE:
			damage(body.DAMAGE, global_position - body.global_position, body)

func loop_holes():
	#EDIT
	return
	if get_collision_layer_value(7) == true:
		return
	for body in center.get_overlapping_bodies():
		if body is Holes:
			var hole_origin = body.map_to_local(body.local_to_map(position.round() + Vector2(0,6))) + Vector2(8,8)
			var hole_hitbox = Rect2(hole_origin - Vector2(5,5), Vector2(10,10))
			position = position.lerp(hole_origin, 0.1) # there's a way to lerp w/ delta time i forgot it tho
			position += Vector2(0, randf_range(-1,0))
			if hole_hitbox.has_point(position + Vector2(0,4)):
				create_hole_fx(hole_origin)
				network.peer_call(self, "create_hole_fx", [hole_origin])
				hole_fall()
				network.peer_call(self, "hole_fall")

func hole_fall():
	pass # has always been this way

func create_hole_fx(pos):
	var hole_fx = preload("res://effects/hole_falling.tscn").instantiate()
	map.add_child(hole_fx)
	hole_fx.position = pos
	sfx.play("fall")
	
func create_drowning_fx(pos):
	var drowning_fx = preload("res://effects/drowning.tscn").instantiate()
	map.add_child(drowning_fx)
	drowning_fx.position = pos
	sfx.play("drown")

func damage(amount, dir, damager=null):
	if is_in_group("invunerable"):
		return
	if hitstun == 0 && state != "menu":
		if amount != 0:
			sfx.play(hurt_sfx)
			set_hurt_texture(true)
			network.peer_call(self, "set_hurt_texture", [true])
			if TYPE == "PLAYER":
				add_to_group("invunerable")
				invunerable = 60
		hitstun = 10
		update_health(-amount)
		knockdir = dir
		if damager != null:
			emit_signal("damaged", damager)
			if health <= 0:
				emit_signal("killed", damager)

func update_health(amount):
	health = max(min(health + amount, MAX_HEALTH), 0)
	emit_signal("health_changed")

func check_for_death():
	pass

@rpc("any_peer") func set_hurt_texture(h):
	sprite.material.set_shader_parameter("is_hurt", h)

func anim_switch(a):
	var newanim: String = str(a, spritedir)
	if ["Left","Right"].has(spritedir):
		newanim = str(a, "Side")
	if anim.current_animation != newanim:
		anim.play(newanim)
	animation = newanim

@rpc("any_peer", "call_local") func use_weapon(weapon_name, input="A"):
	var weapon = global.weapons_def[weapon_name]
	var new_weapon :Node2D = load(weapon.path).instantiate()
	
	var weapon_group = str(weapon_name, name)
	new_weapon.add_to_group(weapon_group)
	new_weapon.add_to_group(name)
	add_child(new_weapon)
	
	new_weapon.set_multiplayer_authority(get_multiplayer_authority())
	#if get_tree().get_nodes_in_group(weapon_group).size() > new_weapon.MAX_AMOUNT:
	if get_tree().get_nodes_in_group(weapon_group).size() > new_weapon.MAX_AMOUNT:
		new_weapon.delete()
		return
	
	if is_multiplayer_authority() && is_in_group("player") && weapon.ammo_type != "":
		if global.ammo[weapon.ammo_type] <= 0:
			new_weapon.delete()
			await get_tree().create_timer(0.05).timeout # hacky
			network.peer_call(self, "remove_last_item", [weapon_group])
			return
		global.ammo[weapon.ammo_type] -= 1
		emit_signal("update_count")
	
	new_weapon.input = input
	new_weapon.start()

func remove_last_item(group):
	get_tree().get_nodes_in_group(group).back().queue_free()

func position_changed(value):
	pos = value
	# EDITED 12/4
	#tween.interpolate_property(self, "position", position, pos, network.tick_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#tween.start()
	create_tween().tween_property(self,"position",position,network.tick_time)

func animation_changed(value):
	animation = value
	if anim.current_animation != value:
		anim.play(value)

func set_health(value):
	health = value
	
func reset_collision():
	$CollisionShape2D.disabled = false
