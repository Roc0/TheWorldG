extends KinematicBody

# class_name Player

# Movement
var velocity := Vector3.ZERO
var direction := Vector3.ZERO
var facing_direction := 0.0

const MAX_SPEED := 20
const ACCEL := 5.0
const DECCEL := 15.0
const JUMP_SPEED := 15
const GRAVITY := -45

func _process(delta : float) -> void:
	#if Client.edit_mode:
		move(delta)
		face_forward()
	
func move(delta : float) -> void:
	var movement_dir := get_2d_movement()
	var camera_xform := ($Camera as Camera).get_global_transform()
	
	direction = Vector3.ZERO
	
	direction += camera_xform.basis.z.normalized() * movement_dir.y
	direction += camera_xform.basis.x.normalized() * movement_dir.x
	
	direction = move_vertically(direction, delta)
	velocity = h_accel(direction, delta)
	
	#warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector3.UP)
	
func move_vertically(dir : Vector3, delta : float) -> Vector3:
	velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("ui_accept") && is_on_floor():
		velocity.y = JUMP_SPEED
	if is_on_floor():
		velocity.y = 0
	
	dir.y = 0
	dir = dir.normalized()
	return dir

func h_accel(dir : Vector3, delta : float) -> Vector3:
	var vel_2d := velocity
	vel_2d.y = 0
	
	var target := dir
	target *= MAX_SPEED
	
	var accel : float
	if dir.dot(vel_2d) > 0:
		accel = ACCEL
	else:
		accel = DECCEL
		
	vel_2d = vel_2d.linear_interpolate(target, accel * delta)
	
	velocity.x = vel_2d.x
	velocity.z = vel_2d.z
	
	return velocity

func get_2d_movement() -> Vector2:
	var movement_vector := Vector2()
	
	if Input.is_action_pressed("ui_up") && !Input.is_action_just_pressed("ui_down"):
		movement_vector.y = -1
		facing_direction = 0
	if Input.is_action_pressed("ui_down") && !Input.is_action_just_pressed("ui_up"):
		movement_vector.y = 1
		facing_direction = PI
	
	if Input.is_action_pressed("ui_left") && !Input.is_action_just_pressed("ui_right"):
		movement_vector.x = -1
		facing_direction = PI * 0.5
	if Input.is_action_pressed("ui_right") && !Input.is_action_just_pressed("ui_left"):
		movement_vector.x = 1
		facing_direction = PI * 1.5
	
	return movement_vector.normalized()
	
func face_forward() -> void:
	($Body as MeshInstance).rotation.y = facing_direction
	
