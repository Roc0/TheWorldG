extends Spatial

var ui
var space_world

# Called when the node enters the scene tree for the first time.
func _ready():
	ui = get_node("../UI")
	space_world = Client.client_app.get_space_world()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func enter_world():
	space_world.say("enter_world")
	
	var mesh = load("res://Meshes/spaces/xinshoucun/undulating1.obj")
	var terrain = get_node("./Terrain")
	terrain.set_mesh(mesh)

	var b = space_world.setup_world(self)
	
	var t = get_node("./TerrainMesh")
	print(t.name)
