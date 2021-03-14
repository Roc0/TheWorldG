extends Spatial

var ui
var space_world
var debug_text

onready var player : KinematicBody = Globals.player

# Called when the node enters the scene tree for the first time.
func _ready():
	var _result = get_tree().get_root().connect("size_changed", self, "resizing")

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
	Client.client_app.debug_print("enter_world - start")
	
	var _ret = space_world.enter_world()

	if Globals.debug_enabled:
		var terrain_mesh : MeshInstance = get_node("./TerrainMesh")
		var aabb : AABB = terrain_mesh.get_aabb()
		var starting_point : Vector3 = aabb.position
		var ending_point : Vector3 = aabb.position + aabb.size
		var player_pos := Vector3( (ending_point.x + starting_point.x) / 2, ending_point.y, (ending_point.z + starting_point.z) / 2)
		player.transform.origin = player_pos
		var body : MeshInstance = player.get_node("Body")
		#var r = body.mesh.radius
		aabb = body.get_aabb()
		debug_text = get_node_or_null("./DebugText")
		if debug_text != null:
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
	
	Client.client_app.debug_print("enter_world - end")

func exit_world():
	Client.client_app.debug_print("exit_world - start")
	var _ret = space_world.exit_world()
	Client.client_app.debug_print("exit_world - end")

func _process(_delta):
	var world_camera : Camera = get_node_or_null("./WorldCamera")
	if world_camera != null:
		
	if world_camera != null and Globals.debug_enabled:
		var active_camera : Camera = world_camera.get_active_camera()
		var lblCamRot = get_node_or_null("./DebugText/LabelCamRot")
		var lblCamPos = get_node_or_null("./DebugText/LabelCamPos")
		if lblCamRot != null and lblCamPos != null and active_camera != null:
			lblCamRot.text = "Cam Rot: " + str(active_camera.global_transform.basis.get_euler().x) + " " + str(active_camera.global_transform.basis.get_euler().y) + " " + str(active_camera.global_transform.basis.get_euler().z)
			lblCamPos.text = "Cam Pos: " + str(active_camera.global_transform.origin.x) + " " + str(active_camera.global_transform.origin.y) + " " + str(world_camera.global_transform.origin.z)
	# DEBUG
	#var entities : Spatial = get_node("./Entities")
	#for entity in (entities.get_children()):
	#	var e : RigidBody = entity.get_node("Entity")
	#	var n = e.name
	#	var p = e.get_position_in_parent()
	#	var o = e.transform.origin
	#	var b = e.transform.basis
	# DEBUG

func resizing():
	if Globals.debug_enabled:
		var lblCamRot = get_node_or_null("./DebugText/LabelCamRot")
		var lblCamPos = get_node_or_null("./DebugText/LabelCamPos")
		if lblCamRot != null and lblCamPos != null:
			lblCamRot.rect_position.x = 0
			lblCamRot.rect_position.y = 0
			lblCamPos.rect_position.x = lblCamRot.rect_position.x
			lblCamPos.rect_position.y = lblCamRot.rect_position.y + lblCamRot.rect_size.y
			
