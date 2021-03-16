extends Spatial

var ui
var space_world
var debug_text
var active_camera : Camera = null
var _active_camera_changed : bool = false
var active_camera_global_rot : Vector3
var active_camera_global_pos : Vector3
var fps := 0.0

onready var player : KinematicBody = Globals.player

# Called when the node enters the scene tree for the first time.
func _ready():
	var _result = get_tree().get_root().connect("size_changed", self, "resizing")

	ui = get_node("../UI")
	space_world = Client.client_app.get_space_world()
	space_world.connect("active_camera_changed", self, "active_camera_changed", [])
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if ui.is_in_world_state():
			get_tree().set_input_as_handled()
			exit_world()
			ui.logout_from_server()
			ui.set_game_state(ui.STATE_LOGIN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	fps = Engine.get_frames_per_second()
	
	if _active_camera_changed:
		_active_camera_changed = false
		var world_camera : Camera = get_node_or_null("./WorldCamera")
		if world_camera != null:
			active_camera = world_camera.get_active_camera()

	if active_camera != null:
		active_camera_global_rot = active_camera.global_transform.basis.get_euler()
		active_camera_global_pos = active_camera.global_transform.origin

	if Globals.debug_enabled and ui.game_state == ui.STATE_WORLD:
		$DebugStats.visible = true
	else:
		$DebugStats.visible = false
	
		# DEBUG
	#var entities : Spatial = get_node("./Entities")
	#for entity in (entities.get_children()):
	#	var e : RigidBody = entity.get_node("Entity")
	#	var n = e.name
	#	var p = e.get_position_in_parent()
	#	var o = e.transform.origin
	#	var b = e.transform.basis
	# DEBUG

func active_camera_changed():
	_active_camera_changed = true

func enter_world():
	Client.client_app.debug_print("enter_world - start")
	var _ret = space_world.enter_world()

	$DebugStats.add_property(self, "fps", "")
	$DebugStats.add_property(self, "active_camera_global_rot", "")
	$DebugStats.add_property(self, "active_camera_global_pos", "")
	
	if Globals.debug_enabled:
		
		# Insert debug player in world - Start
		var aabb : AABB = get_node("./TerrainMesh").get_aabb()
		var starting_point : Vector3 = aabb.position
		var ending_point : Vector3 = aabb.position + aabb.size
		player.transform.origin = Vector3( (ending_point.x + starting_point.x) / 2, ending_point.y, (ending_point.z + starting_point.z) / 2)
		# Insert debug player in world - End
		
	Client.client_app.debug_print("enter_world - end")

func exit_world():
	Client.client_app.debug_print("exit_world - start")

	$DebugStats.remove_property(self, "fps")
	$DebugStats.remove_property(self, "active_camera_global_rot")
	$DebugStats.remove_property(self, "active_camera_global_pos")
		
	var _ret = space_world.exit_world()

	Client.client_app.debug_print("exit_world - end")

func resizing():
	pass	
