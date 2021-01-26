extends Spatial

var ui
var space_world
var debug_text

# Called when the node enters the scene tree for the first time.
func _ready():
	ui = get_node("../UI")
	space_world = Client.client_app.get_space_world()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	#print("World: " + event.as_text())
	# Shortcut for debug
	if event.is_action_pressed("ui_cancel"):
		if ui.is_in_world_state():
			get_tree().set_input_as_handled()
			exit_world()
			ui.logout_from_server()
			ui.set_game_state(ui.STATE_LOGIN)

func enter_world():
	space_world.say("enter_world - start")
	
	var ret = space_world.enter_world(self)

	debug_text = get_node("./DebugText")
	var lbl : Label = Label.new()
	lbl.name = "LabelCamRot"
	debug_text.add_child(lbl)
	
	# Debug
	var t = get_node("./TerrainMesh")
	print(t.name)

	# Debug
	var WorldCamera : Camera = get_node("./WorldCamera")
	print(WorldCamera.name)
	#WorldCamera.make_current()

	# Debug CameraTest & TerrainTest 
	#var mesh = load("res://Meshes/spaces/xinshoucun/undulating1.obj")
	#var terrain = get_node("./TerrainTest")
	#terrain.set_mesh(mesh)
	#var cam = get_node("./CameraTest")
	#cam.far = 1000
	#cam.mouse_mode = 2
	#var terrain_mesh = space_world.get_mesh_instance()
	#var aabb : AABB = terrain_mesh.get_aabb()
	#var starting_point : Vector3 = aabb.position
	#var ending_point : Vector3 = aabb.position + aabb.size
	#cam.set_perspective(45, 1.0, 1000.0)
	#var offset = sqrt( (aabb.size.x * aabb.size.x) + (aabb.size.y * aabb.size.y) + (aabb.size.z * aabb.size.z) ) / 2
	#var camera_pos = Vector3( (ending_point.x + starting_point.x) / 2 + offset, (ending_point.y + starting_point.y) / 2 + offset, (ending_point.z + starting_point.z) / 2 + offset)
	#cam.transform.origin = camera_pos
	# Debug CameraTest & TerrainTest
	
	print("enter_world - end")

func exit_world():
	space_world.say("exit_world - start")
	var ret = space_world.exit_world(self)
	space_world.say("exit_world - end")

func _process(_delta):
	var lbl = get_node_or_null("./DebugText/LabelCamRot")
	if lbl != null:
		var world_camera : Camera = get_node_or_null("./WorldCamera")
		if world_camera != null:
			lbl.text = "Cam Rot: " + str(world_camera.rotation.x) + " " + str(world_camera.rotation.y) + " " + str(world_camera.rotation.z)
