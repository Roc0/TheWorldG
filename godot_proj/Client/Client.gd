extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ClientApp

const ClientApp_AppMode_InitialMenu = 0
const ClientApp_AppMode_World = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.name + ": _ready")
	
	ClientApp = load("res://Client/ClientDll.gdns").new()
	#ClientApp.say(ClientApp.hello("Test", "1", 2))
	connect("tree_exiting", self,"exitFunct",[])
	#add_child(ClientApp) # to activate TheWorld_GD_ClientApp::_ready & TheWorld_GD_ClientApp::_process

	Client.ClientApp.setAppMode(Client.ClientApp_AppMode_InitialMenu, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(self.name + ": _process")
	pass
	
func _init():
	print("Client: _init")
		
func exitFunct():
	print(self.name + ": exitFunct")
	ClientApp.free()
	
