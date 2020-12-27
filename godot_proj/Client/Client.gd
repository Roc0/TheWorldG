extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ClientApp

# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.name + " _ready")
	ClientApp = load("res://Client/ClientDll.gdns").new()
	ClientApp.say(ClientApp.hello("World", "1", 2))
	connect("tree_exiting", self,"exitFunct",[])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass
	
func _init():
	pass	
	
func exitFunct():
	print(self.name + " exitFunct")
	ClientApp.free()
	
