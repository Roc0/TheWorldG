extends Camera

export var mouse_sensitivity := 1000

onready var Player := get_parent() as KinematicBody

func _ready():
	if Client.edit_mode:
		set_process(true)
		set_physics_process(true)
		set_process_input(true)
	else:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)

func _enter_tree() -> void:
	if Client.edit_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _exit_tree() -> void:
	if Client.edit_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse(event as InputEventMouseMotion)
		
func mouse(event : InputEventMouseMotion) -> void:
	Player.set_rotation(look_left_right(-event.relative.x / mouse_sensitivity))
	set_rotation(look_up_down(-event.relative.y / mouse_sensitivity))

func look_left_right(rot : float) -> Vector3:
	return Player.get_rotation() + Vector3(0, rot, 0)

func look_up_down(rot : float) -> Vector3:
	var new_rotation := get_rotation() + Vector3(rot, 0, 0)
	new_rotation.x = clamp(new_rotation.x, PI / -2, PI /2)
	return new_rotation
