extends StaticBody2D

@onready var ray = $RayCast2D
#@onready var tween = $Tween

@onready var target_position = position: set = set_block_position
@onready var pushed = false: set = set_pushed
@onready var home_position = position

func _ready():
	add_to_group("pushable")
	add_to_group("objects")
	set_collision_layer_value(10, 1)
	
func interact(node):
	#if tween.is_active():
		#return
	if network.is_map_host():
		attempt_move(node.last_movedir)
	else:
		network.peer_call_id(network.get_map_host(), self, "attempt_move", [node.last_movedir])

func attempt_move(direction):
	ray.target_position = direction * 16
	await get_tree().create_timer(0.05).timeout
	if !ray.is_colliding() && !pushed:
		target_position = (position + direction * 16).snapped(Vector2(16,16)) - Vector2(8,8)
		set_pushed(true)
		move_to(target_position)
		network.peer_call(self, "move_to", [position, target_position])
		network.peer_call(self, "set_pushed", [pushed])

func set_block_position(value):
	target_position = value
	snap_to(target_position)

func set_pushed(value):
	pushed = value

func move_to(target_pos):
	create_tween().tween_property(self,"position",target_pos,1)
	sfx.play("push")

func snap_to(target_pos):
	create_tween().tween_property(self,"position",target_pos,0.1)
	
func set_default_state():
	set_pushed(false)
	target_position = home_position
	snap_to(home_position)
	
