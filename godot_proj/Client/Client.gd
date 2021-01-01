extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ClientApp

const ClientApp_AppMode_InitialMenu = 0
const ClientApp_AppMode_World = 1

const ClientApp_Login_NotDone = 0
const ClientApp_Login_Started = 1
const ClientApp_Login_Done = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.name + ": _ready")
	
	#var root = get_tree().get_root()
	#var current_scene = root.get_child(root.get_child_count() - 1)
	#var node_count = get_tree().get_node_count()
	#var child_count = root.get_child_count()
	#var child_nodes = root.get_children()
	#for n in child_nodes:
	#	print(n.name)
	
	ClientApp = load("res://Client/ClientDll.gdns").new()
	#ClientApp.say(ClientApp.hello("Test", "1", 2))
	var result = connect("tree_exiting", self,"exitFunct",[])
	
	#add_child(ClientApp) # to activate TheWorld_GD_ClientApp::_ready & TheWorld_GD_ClientApp::_process
	
	result = ClientApp.Init()
	ClientApp.setAppMode(ClientApp_AppMode_InitialMenu, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(self.name + ": _process")
	pass
	
func _init():
	print("Client: _init")
		
func exitFunct():
	print(self.name + ": exitFunct")
	if (ClientApp.getLoginStatus() == ClientApp_Login_Done):
		ClientApp.Logout()
	Client.ClientApp.Destroy()
	ClientApp.free()
	
