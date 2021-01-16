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
	
	#get_node("../World/WorldLogoutButton").rect_position.x = 
	# position Logout Button
	var cam = get_node("./Camera")
	#cam.set_enabled(true)
	cam.far = 1000
	cam.mouse_mode = 2

	#var mesh = load("res://Meshes/spaces/xinshoucun/undulating1.obj")
	#var terrain = get_node("./Terrain")
	#terrain.set_mesh(mesh)

	var bret = space_world.setup_world(self)
	
	var t = get_node("./TerrainMesh")
	print(t.name)
		
	var WorldCamera = get_node("./WorldCamera")
	print(WorldCamera.name)

func exit_world():
	space_world.say("exit_world")
