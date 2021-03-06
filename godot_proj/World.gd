extends Spatial

var ui
var space_world
var debug_text
var active_camera : Camera = null
var _active_camera_changed : bool = false
var active_camera_global_rot : Vector3
var active_camera_global_pos : Vector3
var fps := 0.0
var player_hp := -1
var player_mp := -1
var player_id := -1
var mouse_pos : Vector2
var mouse_ptr_pos_in_world : Vector3
var mouse_ptr_normal_in_world : Vector3
var mouse_ptr_name_in_world : String
var mouse_ptr_id_in_world : int

onready var player : KinematicBody = Globals.player

# Called when the node enters the scene tree for the first time.
func _ready():
	var _result = get_tree().get_root().connect("size_changed", self, "resizing")

	ui = get_node("../UI")
	space_world = Client.client_app.get_space_world()
	space_world.connect("active_camera_changed", self, "active_camera_changed", [])
	
func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			if ui.is_in_world_state():
				get_tree().set_input_as_handled()
				exit_world()
				ui.logout_from_server()
				ui.set_game_state(ui.STATE_LOGIN)
	elif event is InputEventMouseMotion:
		mouse_pos = event.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	fps = Engine.get_frames_per_second()
	
	if player_id != -1:
		player_hp = Client.client_app.get_hp_by_id(player_id)
		player_mp = Client.client_app.get_mp_by_id(player_id)
	
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

func _physics_process(_delta):
	if active_camera != null:
		var ray_origin : Vector3 = active_camera.project_ray_origin(mouse_pos)
		var ray_direction : Vector3 = active_camera.project_ray_normal(mouse_pos)
		var hit = get_world().get_direct_space_state().intersect_ray(ray_origin, ray_origin + ray_direction * 1000.0)
		if hit.size() != 0:
			mouse_ptr_name_in_world = hit.collider.get_name()
			mouse_ptr_id_in_world = hit.collider.get_instance_id()
			mouse_ptr_pos_in_world = hit.position
			mouse_ptr_normal_in_world = hit.normal

func active_camera_changed():
	_active_camera_changed = true

func enter_world():
	Client.client_app.debug_print("enter_world - start")
	
	player_id = Client.client_app.get_player_id()
	
	var _ret = space_world.enter_world()

	$DebugStats.add_property(self, "fps", "")
	$DebugStats.add_property(self, "active_camera_global_rot", "")
	$DebugStats.add_property(self, "active_camera_global_pos", "")
	$DebugStats.add_property(self, "player_hp", "")
	$DebugStats.add_property(self, "player_mp", "")
	$DebugStats.add_property(self, "mouse_ptr_pos_in_world", "")
	$DebugStats.add_property(self, "mouse_ptr_normal_in_world", "")
	$DebugStats.add_property(self, "mouse_ptr_name_in_world", "")
	$DebugStats.add_property(self, "mouse_ptr_id_in_world", "")
	
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
	$DebugStats.remove_property(self, "player_hp")
	$DebugStats.remove_property(self, "player_mp")
	$DebugStats.remove_property(self, "mouse_ptr_pos_in_world")
	$DebugStats.remove_property(self, "mouse_ptr_normal_in_world")
	$DebugStats.remove_property(self, "mouse_ptr_name_in_world")
	$DebugStats.remove_property(self, "mouse_ptr_id_in_world")

	var _ret = space_world.exit_world()

	player_id = -1
	
	Client.client_app.debug_print("exit_world - end")

func resizing():
	pass	
