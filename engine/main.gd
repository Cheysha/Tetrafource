class_name Main
extends Control

var default_map = "res://maps/shrine.tmx"
var default_entrance = "player_start"
@export var default_port : int = 7777

@onready var address_line : LineEdit = $multiplayer/Direct/address
@onready var lobby_line : LineEdit = $multiplayer/Automatic/lobby
@onready var singleplayer_focus : Button = $top/VBoxContainer/singleplayer
@onready var loading_screen : Control = $loading_screen_layer/loading_screen


func _ready():
	$AnimatedSprite2D.play()
	global.load_options()
	hide_menus()
	$top.show()
	
	get_tree().get_multiplayer().connect("connected_to_server", Callable(self, "_client_connect_ok"))
	get_tree().get_multiplayer().connect("connection_failed", Callable(self, "_client_connect_fail"))

	get_tree().set_auto_accept_quit(false)
	
	if OS.get_name() == "HTML5":
		$multiplayer/Manual/host.disabled = true
	
	#For server commandline arguments. Searches for ones passed, then tries to set ones that exist.
	#Puts arguments passed as "--example=value" in a dictionary.
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	if "map" in arguments:
		var map_arg = arguments.get("map").rsplit("/maps/")[1]
		var map_path = str("res://maps/", map_arg)
		default_map = map_path
		default_entrance = ""
		await get_tree().idle_frame
		host_server(false, 0, 0, 1)
		
	#this overrides the default port of 7777
	if("port" in arguments):
		default_port = int(arguments["port"])
		get_node("panel/address").set_text("127.0.0.1:" + arguments["port"])
	
	if OS.get_name() == "Server" || arguments.get("dedicatedserver") == "true":
		var empty_timeout = get_empty_server_timeout(arguments)
		set_dedicated_server(empty_timeout)

	await get_tree().create_timer(0.5).timeout
	sfx.set_music("shrine", "quiet")
	singleplayer_focus.grab_focus()

func get_empty_server_timeout(arguments):
	var empty_timeout
	var empty_timeout_arg = arguments.get("empty-server-timeout")   # don't set default here, fair enough
	if empty_timeout_arg != null:
		if empty_timeout_arg.is_valid_int():
			var empty_timeout_arg_int = int(empty_timeout_arg)
			if empty_timeout_arg_int >= 0:
				empty_timeout = empty_timeout_arg_int
			else:
				print("invalid value for empty-server-timeout - must be an integer >= 0")
		else:
			print("invalid value for empty-server-timeout - must be an integer >= 0")
	
	if empty_timeout == null:
		empty_timeout = 0   # set default here
		print("defaulting empty-server-timeout to %d" % empty_timeout)
	
	if empty_timeout > 0:
		print("empty-server-timeout set to %d seconds" % empty_timeout)
	else:
		print("empty-server-timeout set to 0 - server will not stop when empty")
	
	return empty_timeout

func start_game(dedicated = false, empty_timeout = 0, map = null, entrance = null):
	loading_screen.stop_loading()
	if dedicated:
		network.dedicated = true
		network.empty_timeout = empty_timeout
	network.initialize()
	
	if !dedicated:
		if entrance:
			global.next_entrance = entrance
		else:
			global.next_entrance = default_entrance
		var level
		if map:
			level = load(map).instantiate()
		else:
			level = load(default_map).instantiate()
		get_tree().get_root().add_child(level)
		hide()

func host_server(dedicated = false, empty_timeout:int = 0, port:int = default_port, max_players:int = 16):
	var ws = WebSocketMultiplayerPeer.new()
	ws.create_server(port)
	get_tree().get_multiplayer().set_multiplayer_peer(ws)

	#if ws != connected:
		#print("Port in use")
		#return
	
	start_game(dedicated, empty_timeout)

func join_server(ip:String, port:int):
	loading_screen.with_load("Connecting to host", 75)
	if !ip.is_valid_ip_address():
		print("Invalid IP")
		open_error_message("Invalid IP")
		loading_screen.stop_loading()
		return
	
	var ws = WebSocketMultiplayerPeer.new()
	#ws.connect("server_close_request", Callable(self, "_client_disconnect")) # refactor
	var url = "ws://%s:%s" % [ip, port]
	ws.create_client(url)
	get_tree().get_multiplayer().set_multiplayer_peer(ws)

func _client_connect_ok():
	loading_screen.stop_loading(100)
	start_game()

func _client_connect_fail():
	print("Failed to connect!")
	loading_screen.stop_loading()
	end_game()

func _client_disconnect(code, reason):
	print("Disconnected from server: %s, %s" % [code, reason])
	network.complete(false)
	show()
	if code != OK:
		open_error_message(reason)
		

func end_game():
	network.complete()
	show()
	screenfx.play("default")

func quit_program():
	get_tree().get_multiplayer().multiplayer_peer = null 
	get_tree().quit()
	
func set_dedicated_server(empty_timeout):
	hide_menus()
	host_server(true, empty_timeout)

func get_ipport():
	return address_line.text.rsplit(":")

func hide_menus():
	for node in get_tree().get_nodes_in_group("menu"):
		node.hide()
		
####################################
#EVENTS
####################################

func _notification(n):
	if (n == NOTIFICATION_WM_CLOSE_REQUEST):
		quit_program()
		
func _on_host_pressed():
	host_server(false)

func _on_join_pressed():
	join_server(get_ipport()[0], int(get_ipport()[1]))

func _on_quit_pressed():
	quit_program()

func _on_quickstart_pressed():
	hide_menus()
	$top.show()
	singleplayer_focus.grab_focus()
	host_server(false, 0, 0, 1)

func open_error_message(message):
	hide_menus()
	$message/Label.text = message
	$message.show()
	$message/Button.grab_focus()

func _on_load_pressed():
	hide_menus()
	$player_select/saves.refresh_saves()
	$player_select.show()
	$player_select.show()
	$back.show()
	$back.grab_focus()

func _on_multiplayer_pressed():
	hide_menus()
	$multiplayer.show()
	$back.show()
	$back.grab_focus()

func _on_options_pressed():
	hide_menus()
	$options.show()
	$back.show()
	$back.grab_focus()

func _on_back_pressed():
	if $options.is_visible_in_tree():
		global.save_options()
	hide_menus()
	$top.show()
	singleplayer_focus.grab_focus()

func _on_returned_pressed():
	hide()

func _on_save_pressed():
	global.save_options()

func _on_mouse_entered():
	sfx.play("item_select")

func _on_credits_pressed():
	hide_menus()
	$credits.show()
	$back.show()
	$back.grab_focus()
