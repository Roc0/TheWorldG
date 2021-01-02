extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var client_app = preload("res://Client/ClientDll.gdns").new()

const ClientApp_AppMode_InitialMenu = 0
const ClientApp_AppMode_World = 1

const ClientApp_Login_NotDone = 0
const ClientApp_Login_Started = 1
const ClientApp_Login_Done = 2

var time_from_last_process = 0
const Time_Period_Process = 0.001	# 1 millisecond

# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.name + ": _ready")
	#client_app.say(ClientApp.hello("Test", "1", 2))
	#add_child(ClientApp) # to activate TheWorld_GD_ClientApp::_ready & TheWorld_GD_ClientApp::_process
	
	#var root = get_tree().get_root()
	#var current_scene = root.get_child(root.get_child_count() - 1)
	#var node_count = get_tree().get_node_count()
	#var child_count = root.get_child_count()
	#var child_nodes = root.get_children()
	#for n in child_nodes:
	#	print(n.name)
	
	var result = connect("tree_exiting", self, "exitFunct",[])
	
	result = client_app.init()
	client_app.set_app_mode(ClientApp_AppMode_InitialMenu, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(self.name + ": _process")
	
	var do_process = false
	time_from_last_process += _delta
	if time_from_last_process > Time_Period_Process:
		time_from_last_process = 0
		do_process = true
	
	if !do_process:
		pass

	# Manage Server Event Message Pump
	#var do_sleep = client_app.get_do_sleep_in_main_loop()
	#if (!do_sleep):
		#print(self.name + ": _process - call client_app.message_pump()")
	client_app.message_pump()
	
func _init():
	print("Client: _init")
		
func exitFunct():
	print(self.name + ": exitFunct")
	if (client_app.get_login_status() == ClientApp_Login_Done):
		client_app.logout()
	client_app.destroy()
	client_app.free()
	
