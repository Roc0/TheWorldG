extends Spatial

var ui
var space_world
var debug_text

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", self, "resizing")

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
	
	var ret = space_world.enter_world()

	debug_text = get_node("./DebugText")
	var lblCamRot : Label = Label.new()
	lblCamRot.name = "LabelCamRot"
	debug_text.add_child(lblCamRot)
	lblCamRot.rect_position.x = 0
	lblCamRot.rect_position.y = 0
	var lblCamPos : Label = Label.new()
	lblCamPos.name = "LabelCamPos"
	debug_text.add_child(lblCamPos)
	lblCamPos.rect_position.x = lblCamRot.rect_position.x
	lblCamPos.rect_position.y = lblCamRot.rect_position.y + lblCamRot.rect_size.y
	
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
	var ret = space_world.exit_world()
	space_world.say("exit_world - end")

func _process(_delta):
	var world_camera : Camera = get_node_or_null("./WorldCamera")
	if world_camera != null:
		var lblCamRot = get_node_or_null("./DebugText/LabelCamRot")
		var lblCamPos = get_node_or_null("./DebugText/LabelCamPos")
		if lblCamRot != null and lblCamPos != null:
			lblCamRot.text = "Cam Rot: " + str(world_camera.rotation.x) + " " + str(world_camera.rotation.y) + " " + str(world_camera.rotation.z)
			lblCamPos.text = "Cam Pos: " + str(world_camera.transform.origin.x) + " " + str(world_camera.transform.origin.y) + " " + str(world_camera.transform.origin.z)

func resizing():
	var lblCamRot = get_node_or_null("./DebugText/LabelCamRot")
	var lblCamPos = get_node_or_null("./DebugText/LabelCamPos")
	if lblCamRot != null and lblCamPos != null:
		lblCamRot.rect_position.x = 0
		lblCamRot.rect_position.y = 0
		lblCamPos.rect_position.x = lblCamRot.rect_position.x
		lblCamPos.rect_position.y = lblCamRot.rect_position.y + lblCamRot.rect_size.y
			
