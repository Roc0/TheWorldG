extends Spatial

var threads : Array

var chunks := {}
var chunks_being_generated := {}

var noise : OpenSimplexNoise
export var material : Material

onready var player = Globals.player
var player_chunk_grid_position : Vector2

func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 7.0
	noise.persistence = 0.2
	
	#var chunk := Chunk.new(Vector2(0, 0), noise, material)
	#chunk.generate()
	#add_child(chunk)
	
	player_chunk_grid_position = get_chunk_grid_position_for(player.translation)
	# generate chunk at the origin
	generate_chunk([Chunk.new(player_chunk_grid_position, noise, material), null])

func generate_chunk(arr) -> void:
	var chunk = arr[0]
	var thread = arr[1]
	
	chunk.generate()
	call_deferred("finished_generating_chunk", thread, chunk)

func finished_generating_chunk(thread, chunk):
	chunks[chunk.key] = chunk
	chunks_being_generated.erase[chunk.key]

func get_chunk_grid_position_for(position : Vector3) -> Vector2:
	var start = Vector2(position.x, position.z)
	if start.x > 0:
		start.x += Globals.CHUNK_SIZE / 2.0
	if start.x < 0:
		start.x -= Globals.CHUNK_SIZE / 2.0
	if start.y > 0:
		start.y += Globals.CHUNK_SIZE / 2.0
	if start.y < 0:
		start.y -= Globals.CHUNK_SIZE / 2.0
	
	return Vector2(
		int(start.x / Globals.CHUNK_SIZE),
		int(start.y / Globals.CHUNK_SIZE)
	)
